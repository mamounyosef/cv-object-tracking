function varargout = meanShift(mode, varargin)
% meanShift - Classic color-histogram mean-shift tracker.
%
% Tracks a single user-selected object by its colour distribution:
%   1. Build a Hue histogram of the object inside the initial ROI.
%   2. Each frame, back-project that histogram onto the new frame
%      (every pixel -> "how well does my colour match the target?").
%   3. Iterate mean-shift: slide the box toward the weighted centroid
%      of the back-projection until it stops moving.
%
% Usage:
%   state                  = meanShift('init',   frame, bbox, params)
%   [state, bbox, backImg] = meanShift('update', frame, state, params)
%
% params fields (all optional):
%   .nbins    - number of Hue histogram bins.       Default 16.
%   .maxIter  - max mean-shift iterations per frame. Default 10.
%   .epsilon  - convergence threshold in pixels.     Default 1.

    switch mode
        case 'init'
            frame  = varargin{1};
            bbox   = varargin{2};
            params = struct();
            if numel(varargin) >= 3 && ~isempty(varargin{3})
                params = varargin{3};
            end
            P = applyDefaults(params);

            hue = hueChannel(frame);
            roiHue = cropToBBox(hue, bbox);

            % Normalised Hue histogram of the target region.
            targetHist = imhist(roiHue, P.nbins);
            s = sum(targetHist);
            if s > 0, targetHist = targetHist / s; end

            state = struct( ...
                'bbox',       bbox, ...
                'targetHist', targetHist, ...
                'nbins',      P.nbins);
            varargout = {state};

        case 'update'
            frame  = varargin{1};
            state  = varargin{2};
            params = struct();
            if numel(varargin) >= 3 && ~isempty(varargin{3})
                params = varargin{3};
            end
            P = applyDefaults(params);

            hue = hueChannel(frame);
            [H, W] = size(hue);

            % --- Back-projection: map each pixel's hue to its target
            % histogram weight. Bright = matches the object's colour. ----
            binIdx  = min(state.nbins, floor(hue * state.nbins) + 1);
            backProj = state.targetHist(binIdx);
            backProj = reshape(backProj, H, W);

            % --- Mean-shift iterations ----------------------------------
            bbox = state.bbox;
            for it = 1:P.maxIter
                region = cropToBBox(backProj, bbox);
                tot = sum(region(:));
                if isempty(region) || tot <= 0, break; end

                [rr, cc] = size(region);
                [Xg, Yg] = meshgrid(1:cc, 1:rr);
                cx = sum(Xg(:) .* region(:)) / tot;
                cy = sum(Yg(:) .* region(:)) / tot;

                dx = cx - cc/2;
                dy = cy - rr/2;
                bbox(1) = bbox(1) + dx;
                bbox(2) = bbox(2) + dy;
                bbox = clampBBox(bbox, [H W]);

                if abs(dx) < P.epsilon && abs(dy) < P.epsilon
                    break;
                end
            end

            state.bbox = bbox;
            varargout = {state, bbox, backProj};

        otherwise
            error('meanShift:badMode', 'Unknown mode "%s"', mode);
    end
end


% ============================================================================
% Local helpers
% ============================================================================

function P = applyDefaults(P)
    if ~isfield(P,'nbins'),   P.nbins   = 16; end
    if ~isfield(P,'maxIter'), P.maxIter = 10; end
    if ~isfield(P,'epsilon'), P.epsilon = 1;  end
end

function hue = hueChannel(frame)
    if size(frame,3) == 3
        hsv = rgb2hsv(frame);
        hue = hsv(:,:,1);              % already in [0,1]
    else
        hue = im2double(frame);       % grayscale fallback: use intensity
    end
end

function out = cropToBBox(img, bbox)
    [H, W] = size(img);
    x1 = max(1, round(bbox(1)));
    y1 = max(1, round(bbox(2)));
    x2 = min(W, round(bbox(1) + bbox(3) - 1));
    y2 = min(H, round(bbox(2) + bbox(4) - 1));
    if x2 < x1 || y2 < y1
        out = [];
    else
        out = img(y1:y2, x1:x2);
    end
end

function bb = clampBBox(bb, sz)
    H = sz(1); W = sz(2);
    w = min(bb(3), W);
    h = min(bb(4), H);
    x = min(max(1, bb(1)), W - w + 1);
    y = min(max(1, bb(2)), H - h + 1);
    bb = [x y w h];
end
