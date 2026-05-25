function varargout = sceneFlow(mode, varargin)
% sceneFlow - Whole-frame Lucas-Kanade scene-motion tracker.
%
% No ROI, no per-object identity. The algorithm follows the textbook LK
% pipeline from the course slides:
%
%   1. Detect Shi-Tomasi corners across the ENTIRE frame.
%   2. Run pyramidal Lucas-Kanade between consecutive frames on every
%      tracked point (handled by vision.PointTracker).
%   3. Each point's displacement = its optical-flow vector.
%   4. Points whose flow magnitude exceeds motionThresh are "moving".
%   5. Cluster moving points spatially (DBSCAN). Each cluster's axis-
%      aligned bounding box marks an "object in motion".
%
% Periodic re-detection tops up the point pool so that newly-appearing
% objects (e.g. a ball emerging from behind an obstacle) get covered.
%
% See TRACKER_CONTRACT.md for the calling convention.

    switch mode
        case 'init'
            frame  = varargin{1};
            params = struct();
            if numel(varargin) >= 2 && ~isempty(varargin{2})
                params = varargin{2};
            end
            P = applyDefaults(params);

            gray   = toGray(frame);
            points = detectCorners(gray, P);

            tracker = vision.PointTracker( ...
                'MaxBidirectionalError', inf, ...
                'BlockSize',             [P.blockSize P.blockSize], ...
                'NumPyramidLevels',      P.pyrLevels);
            initialize(tracker, points, gray);

            state = struct( ...
                'tracker',           tracker, ...
                'points',            points, ...     % Nx2 current positions
                'framesSinceDetect', 0);

            varargout = {state};

        case 'update'
            frame  = varargin{1};
            state  = varargin{2};
            params = struct();
            if numel(varargin) >= 3 && ~isempty(varargin{3})
                params = varargin{3};
            end
            P = applyDefaults(params);

            gray = toGray(frame);

            % --- 1. Step LK on every tracked point -----------------------
            [newPts, isFound] = step(state.tracker, gray);
            oldValid = state.points(isFound, :);
            newValid = newPts(isFound, :);

            % --- 2. Per-point flow vectors -------------------------------
            % flow is Nx4: [oldX oldY newX newY]; used by the GUI to draw
            % the quiver overlay on axFilt.
            if isempty(newValid)
                flow = zeros(0, 4);
            else
                flow = [oldValid newValid];
            end

            % --- 3. Filter to MOVING points ------------------------------
            bboxes = {};
            if ~isempty(newValid)
                disp_ = newValid - oldValid;
                mag   = sqrt(sum(disp_.^2, 2));
                moving = mag > P.motionThresh;
                movingPts = newValid(moving, :);

                % --- 4. Cluster moving points (DBSCAN) ------------------
                if size(movingPts, 1) >= P.minClusterPts
                    labels = dbscan(movingPts, P.clusterRadius, P.minClusterPts);
                    ids = unique(labels);
                    ids = ids(ids > 0);   % drop noise (-1)
                    for ii = 1:numel(ids)
                        pts = movingPts(labels == ids(ii), :);
                        x1 = min(pts(:,1)); x2 = max(pts(:,1));
                        y1 = min(pts(:,2)); y2 = max(pts(:,2));
                        bboxes{end+1} = [x1, y1, x2-x1+1, y2-y1+1]; %#ok<AGROW>
                    end
                end
            end

            % --- 5. Persist points & periodic re-detection ---------------
            % Keep all surviving tracked points in the tracker.
            if ~isempty(newValid)
                setPoints(state.tracker, newValid);
                state.points = newValid;
            end
            state.framesSinceDetect = state.framesSinceDetect + 1;

            % Re-detect when point count drops or after redetectEvery frames.
            % New corners are merged with existing tracks; a minimum-
            % separation check stops the same corner being tracked twice.
            if size(state.points, 1) < P.minPoints || ...
                    state.framesSinceDetect >= P.redetectEvery
                newCorners = detectCorners(gray, P);
                merged = mergePoints(state.points, newCorners, P);
                if ~isempty(merged)
                    setPoints(state.tracker, merged);
                    state.points = merged;
                end
                state.framesSinceDetect = 0;
            end

            varargout = {state, bboxes, flow};

        otherwise
            error('sceneFlow:badMode', 'Unknown mode "%s"', mode);
    end
end


% ============================================================================
% Local helpers
% ============================================================================

function P = applyDefaults(P)
    if ~isfield(P,'motionThresh'),  P.motionThresh   = 1.5;   end
    if ~isfield(P,'minClusterPts'), P.minClusterPts  = 5;     end
    if ~isfield(P,'clusterRadius'), P.clusterRadius  = 25;    end
    if ~isfield(P,'pyrLevels'),     P.pyrLevels      = 3;     end
    if ~isfield(P,'minPoints'),     P.minPoints      = 50;    end
    if ~isfield(P,'maxPoints'),     P.maxPoints      = 600;   end
    if ~isfield(P,'minQuality'),    P.minQuality     = 0.01;  end
    if ~isfield(P,'blockSize'),     P.blockSize      = 31;    end
    if ~isfield(P,'redetectEvery'), P.redetectEvery  = 30;    end
    if ~isfield(P,'minSeparation'), P.minSeparation  = 5;     end  % px
    if mod(P.blockSize,2) == 0, P.blockSize = P.blockSize + 1; end
end

function g = toGray(frame)
    if size(frame,3) == 3
        g = rgb2gray(frame);
    else
        g = frame;
    end
end

function pts = detectCorners(gray, P)
% Shi-Tomasi corners over the WHOLE frame (no ROI). Capped at maxPoints.
    f = detectMinEigenFeatures(gray, 'MinQuality', P.minQuality);
    if f.Count > P.maxPoints
        f = selectStrongest(f, P.maxPoints);
    end
    pts = f.Location;
end

function out = mergePoints(existing, newPts, P)
% Add newPts to existing, skipping any new point within minSeparation of
% an existing one. Caps the total at maxPoints (drops weakest = newest
% extras first).
    if isempty(existing)
        out = newPts;
    elseif isempty(newPts)
        out = existing;
    else
        keep = true(size(newPts, 1), 1);
        sep2 = P.minSeparation^2;
        for i = 1:size(newPts, 1)
            d2 = (existing(:,1) - newPts(i,1)).^2 + ...
                 (existing(:,2) - newPts(i,2)).^2;
            if any(d2 < sep2)
                keep(i) = false;
            end
        end
        out = [existing; newPts(keep, :)];
    end
    if size(out, 1) > P.maxPoints
        out = out(1:P.maxPoints, :);
    end
end
