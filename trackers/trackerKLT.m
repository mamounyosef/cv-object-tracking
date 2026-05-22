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

            if size(newValid,1) < 1
                % No points survived at all -> lost.
                state.lost = true;
                varargout = {state, [], drawVis(frame, newValid, oldValid, [])};
                return;
            end

            % --- Step 2: estimate geometric transform old -> new ----------
            % Graceful degradation: try the configured transform first
            % (default 'similarity'). If that fails (often because surviving
            % points are nearly collinear), fall back to 'affine', then
            % 'translation' (1 point minimum). estgeotform2d uses RANSAC
            % internally and returns the inlier set, which we use below to
            % filter outliers from the displacement statistics.
            tform = []; inlierMask = [];
            xformLadder = uniqueXformLadder(P.xform);
            for xi = 1:numel(xformLadder)
                xname = xformLadder{xi};
                minPtsForXform = minPointsFor(xname);
                if size(newValid,1) < minPtsForXform, continue; end
                try
                    [tform, inlierMask] = estgeotform2d(oldValid, newValid, ...
                                                       xname, ...
                                                       'MaxNumTrials', 1000, ...
                                                       'Confidence', 99); %#ok<ASGLU>
                    break;
                catch
                    tform = []; inlierMask = [];
                end
            end
            if isempty(tform)
                state.lost = true;
                varargout = {state, [], drawVis(frame, newValid, oldValid, [])};
                return;
            end

            % --- Step 3: update bbox -------------------------------------
            % Two modes, controlled by the "🔒 Lock ROI size" checkbox in
            % the GUI (P.lockSize):
            %
            %   lockSize == true  -> apply ONLY the median translation of
            %       the RANSAC inliers. Width/height are preserved. Stable;
            %       no "bbox drift" growth over time. Default.
            %
            %   lockSize == false -> apply the full geometric transform
            %       (similarity / affine) to all four corners. Allows the
            %       bbox to rotate and scale with the object, but small
            %       per-frame errors compound and the bbox can grow
            %       unboundedly on non-rigid targets.
            if isempty(inlierMask) || ~any(inlierMask)
                inlierMask = true(size(newValid,1),1);   % safety fallback
            end
            inOld = oldValid(inlierMask, :);
            inNew = newValid(inlierMask, :);

            if P.lockSize
                deltaX = median(inNew(:,1) - inOld(:,1));
                deltaY = median(inNew(:,2) - inOld(:,2));
                newBBox = [state.bbox(1) + deltaX, ...
                           state.bbox(2) + deltaY, ...
                           state.bbox(3), ...
                           state.bbox(4)];
                newCorners = state.corners;
                newCorners(:,1) = newCorners(:,1) + deltaX;
                newCorners(:,2) = newCorners(:,2) + deltaY;
            else
                newCorners = transformPointsForward(tform, state.corners);
                newBBox    = cornersToBBox(newCorners, size(gray));
            end
            newBBox = clampBBoxToImage(newBBox, size(gray));

            % --- Step 4: persist INLIER points; re-detect if too few ------
            % Drop outliers from the tracker too, so the next frame works
            % from a cleaner point set.
            state.tracker.setPoints(inNew);
            state.points  = inNew;
            state.corners = newCorners;
            state.bbox    = newBBox;
            state.lost    = false;

            if size(inNew,1) < P.minPoints
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
    if ~isfield(P,'maxBidirErr'), P.maxBidirErr = inf;           end
    % NOTE: MATLAB's default is inf (no bidirectional check). Setting a small
    % finite value (e.g. 2) was too aggressive: many valid points fail the
    % strict forward-then-backward consistency test on the first frame,
    % especially for fast motion or weakly-textured ROIs, causing the tracker
    % to be declared lost almost instantly.
    if ~isfield(P,'blockSize'),   P.blockSize   = 31;            end
    if ~isfield(P,'pyrLevels'),   P.pyrLevels   = 3;             end
    if ~isfield(P,'xform'),       P.xform       = 'similarity';  end
    if ~isfield(P,'lockSize'),    P.lockSize    = true;          end
    % lockSize = true  -> bbox keeps its initial w/h, only translates.
    % lockSize = false -> bbox corners go through the full transform
    %                     (allows rotation + scale, but may drift over time).
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

function ladder = uniqueXformLadder(primary)
% Ordered list of transform types to try, starting from the user-preferred
% one and falling back to looser models (which need fewer points).
    full = {'similarity','affine','translation'};
    if ~ismember(primary, full)
        primary = 'similarity';
    end
    seen = false(size(full));
    ladder = {primary};
    seen(strcmp(full, primary)) = true;
    for k = 1:numel(full)
        if ~seen(k)
            ladder{end+1} = full{k}; %#ok<AGROW>
            seen(k) = true;
        end
    end
    % Force 'translation' as the final guaranteed fallback (1 point min).
    if ~ismember('translation', ladder)
        ladder{end+1} = 'translation'; %#ok<AGROW>
    end
end

function n = minPointsFor(xname)
% Theoretical minimum point count to fit each transform type.
    switch xname
        case 'translation', n = 1;
        case 'similarity',  n = 2;
        case 'affine',      n = 3;
        otherwise,          n = 2;
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
    % Re-detect corners inside the (updated) bbox to keep the point cloud
    % alive. We shrink the ROI by REDETECT_SHRINK on each side before
    % detection so that re-detection cannot pick up background corners that
    % happen to live near the bbox edge (which would drag the next frame's
    % translation estimate toward "no motion").
    REDETECT_SHRINK = 0.15;   % crop 15% off each side
    shrunkBBox = shrinkBBox(bbox, REDETECT_SHRINK);
    newPts = detectShiTomasi(gray, shrunkBBox, P);
    if isempty(newPts)
        return;   % nothing better to do; keep what we have
    end
    setPoints(state.tracker, newPts);
    state.points = newPts;
end

function out = shrinkBBox(bbox, frac)
    % Symmetrically shrink a bbox toward its centre by `frac` on each side.
    dx = bbox(3) * frac;
    dy = bbox(4) * frac;
    out = [bbox(1) + dx, bbox(2) + dy, ...
           max(1, bbox(3) - 2*dx), ...
           max(1, bbox(4) - 2*dy)];
end

function bb = clampBBoxToImage(bb, sz)
    % Keep a bbox fully inside the image while preserving its width/height
    % when possible (we slide rather than crop). If the bbox is wider/taller
    % than the image, we shrink to fit.
    H = sz(1); W = sz(2);
    w = min(bb(3), W);
    h = min(bb(4), H);
    x = bb(1);
    y = bb(2);
    if x < 1,        x = 1;          end
    if y < 1,        y = 1;          end
    if x + w - 1 > W, x = W - w + 1; end
    if y + h - 1 > H, y = H - h + 1; end
    bb = [x y w h];
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
