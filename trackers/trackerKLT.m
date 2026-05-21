function varargout = trackerKLT(mode, varargin)
% trackerKLT - Lucas-Kanade (pyramidal KLT) point tracker.
%
% Algorithm: detect Shi-Tomasi corners inside the user's ROI, track them
% between frames with pyramidal Lucas-Kanade (vision.PointTracker), then
% estimate a geometric transform from the old->new point set and apply it
% to the bounding box corners. Re-detect points when too many are lost.
%
% Parameters (struct fields, all optional):
%   .minPoints    - re-detect when valid point count drops below this. Default 10.
%   .maxPoints    - max corners to detect per (re-)init. Default 100.
%   .minQuality   - Shi-Tomasi min eigenvalue threshold. Default 0.01.
%   .maxBidirErr  - PointTracker bidirectional error in pixels. Default 2.
%   .blockSize    - LK tracking window size (odd integer). Default 31.
%   .pyrLevels    - pyramid levels for coarse-to-fine LK. Default 3.
%   .xform        - 'translation'|'similarity'|'affine'. Default 'similarity'.
%
% See TRACKER_CONTRACT.md for the calling convention.

    switch mode
        case 'init'
            frame  = varargin{1};
            bbox   = varargin{2};
            params = struct();
            if numel(varargin) >= 3 && ~isempty(varargin{3}), params = varargin{3}; end

            P = applyDefaults(params);
            gray = toGray(frame);

            points = detectShiTomasi(gray, bbox, P);

            tracker = vision.PointTracker( ...
                'MaxBidirectionalError', P.maxBidirErr, ...
                'BlockSize',             [P.blockSize P.blockSize], ...
                'NumPyramidLevels',      P.pyrLevels);
            initialize(tracker, points, gray);

            state = struct( ...
                'tracker',  tracker, ...
                'points',   points, ...      % current tracked point locations (Nx2)
                'bbox',     bbox, ...        % current bbox [x y w h]
                'corners',  bboxCorners(bbox), ...  % 4x2 corner pts (TL,TR,BR,BL)
                'lost',     false);

            varargout = {state};

        case 'update'
            frame  = varargin{1};
            state  = varargin{2};
            params = struct();
            if numel(varargin) >= 3 && ~isempty(varargin{3}), params = varargin{3}; end
            P = applyDefaults(params);

            % Once a tracker is marked lost, stay lost cheaply (don't poke
            % vision.PointTracker, which may be in an undefined state).
            if isfield(state,'lost') && state.lost
                varargout = {state, [], []};
                return;
            end

            gray = toGray(frame);

            % --- Step 1: run LK on stored points ---------------------------
            [newPts, isFound] = step(state.tracker, gray);
            oldValid = state.points(isFound, :);
            newValid = newPts(isFound, :);

            if size(newValid,1) < 3
                % Not enough points left to estimate a transform -> lost.
                state.lost = true;
                varargout = {state, [], drawVis(frame, newValid, oldValid, [])};
                return;
            end

            % --- Step 2: estimate geometric transform old -> new ----------
            try
                tform = estgeotform2d(oldValid, newValid, P.xform, ...
                                      'MaxNumTrials', 1000, ...
                                      'Confidence', 99);
            catch
                state.lost = true;
                varargout = {state, [], drawVis(frame, newValid, oldValid, [])};
                return;
            end

            % --- Step 3: transform the bbox corners -----------------------
            newCorners = transformPointsForward(tform, state.corners);
            newBBox    = cornersToBBox(newCorners, size(gray));

            % --- Step 4: persist surviving points; re-detect if too few ----
            state.tracker.setPoints(newValid);
            state.points  = newValid;
            state.corners = newCorners;
            state.bbox    = newBBox;
            state.lost    = false;

            if size(newValid,1) < P.minPoints
                state = reDetect(state, gray, newBBox, P);
            end

            vis = drawVis(frame, newValid, oldValid, newBBox);
            varargout = {state, newBBox, vis};

        otherwise
            error('trackerKLT:badMode','Unknown mode "%s"', mode);
    end
end


% ============================================================================
% Local helpers
% ============================================================================

function P = applyDefaults(P)
    if ~isfield(P,'minPoints'),   P.minPoints   = 10;            end
    if ~isfield(P,'maxPoints'),   P.maxPoints   = 100;           end
    if ~isfield(P,'minQuality'),  P.minQuality  = 0.01;          end
    if ~isfield(P,'maxBidirErr'), P.maxBidirErr = 2;             end
    if ~isfield(P,'blockSize'),   P.blockSize   = 31;            end
    if ~isfield(P,'pyrLevels'),   P.pyrLevels   = 3;             end
    if ~isfield(P,'xform'),       P.xform       = 'similarity';  end
    % blockSize must be odd
    if mod(P.blockSize,2) == 0, P.blockSize = P.blockSize + 1; end
end

function g = toGray(frame)
    if size(frame,3) == 3
        g = rgb2gray(frame);
    else
        g = frame;
    end
end

function pts = detectShiTomasi(gray, bbox, P)
    % Detect Shi-Tomasi (min-eigen) corners restricted to the ROI.
    roi = clampROI(bbox, size(gray));
    f = detectMinEigenFeatures(gray, 'ROI', roi, 'MinQuality', P.minQuality);
    if f.Count > P.maxPoints
        f = selectStrongest(f, P.maxPoints);
    end
    pts = f.Location;   % Nx2 single
end

function roi = clampROI(bbox, sz)
    % MATLAB ROI for detect* functions is [x y w h], 1-indexed, inside image.
    H = sz(1); W = sz(2);
    x = max(1, round(bbox(1)));
    y = max(1, round(bbox(2)));
    w = min(W - x, round(bbox(3)));
    h = min(H - y, round(bbox(4)));
    roi = [x y max(1,w) max(1,h)];
end

function C = bboxCorners(bbox)
    x = bbox(1); y = bbox(2); w = bbox(3); h = bbox(4);
    C = [x      y     ;   % TL
         x+w-1  y     ;   % TR
         x+w-1  y+h-1 ;   % BR
         x      y+h-1];   % BL
end

function bbox = cornersToBBox(C, sz)
    % Axis-aligned tight bounding box around transformed corners, clamped to image.
    H = sz(1); W = sz(2);
    x1 = max(1, min(C(:,1)));
    y1 = max(1, min(C(:,2)));
    x2 = min(W, max(C(:,1)));
    y2 = min(H, max(C(:,2)));
    bbox = [x1 y1 x2-x1+1 y2-y1+1];
end

function state = reDetect(state, gray, bbox, P)
    % Re-detect corners inside the (updated) bbox to keep the point cloud alive.
    newPts = detectShiTomasi(gray, bbox, P);
    if isempty(newPts)
        return;   % nothing better to do; keep what we have
    end
    setPoints(state.tracker, newPts);
    state.points = newPts;
end

function out = drawVis(frame, trackedNow, oldValid, bbox)
    % Overlay: green dots for currently tracked points, plus bbox if present.
    if size(frame,3) == 1
        out = repmat(frame, 1, 1, 3);
    else
        out = frame;
    end
    if ~isempty(trackedNow)
        out = insertMarker(out, trackedNow, '+', 'Color', [0 230 0], 'Size', 5);
    end
    if ~isempty(oldValid) && size(oldValid,1) ~= size(trackedNow,1)
        % Some points were lost this frame - mark them in red at the old loc.
        % (oldValid contains only the survivors here, so this branch is rare.)
    end
    if ~isempty(bbox)
        out = insertShape(out, 'Rectangle', bbox, ...
                          'Color', [255 230 0], 'LineWidth', 2);
    end
end
