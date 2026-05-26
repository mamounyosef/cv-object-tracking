function varargout = sceneFlow(mode, varargin)
% sceneFlow - Dense Lucas-Kanade scene-motion tracker.
%
% This is the MATLAB-documentation-style implementation: it uses the
% built-in opticalFlowLK object and estimateFlow function (the exact
% functions called out in the course material) to compute dense optical
% flow at every pixel, then turns moving pixels into bounding boxes via
% simple connected-component analysis.
%
% Pipeline:
%   1. estimateFlow(opticalFlowLK, frame)  -> flow.Vx, flow.Vy per pixel
%   2. magnitude = sqrt(Vx^2 + Vy^2)
%   3. mask = magnitude > motionThresh
%   4. mask = bwareaopen(mask, minBlobArea)        % drop tiny noise blobs
%   5. regionprops(mask, 'BoundingBox')            % one bbox per blob
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

            % Create the LK optical-flow object exactly as the docs show.
            opticFlow = opticalFlowLK('NoiseThreshold', P.noiseThresh);

            % Prime it with the first frame so the next estimateFlow call
            % has a previous frame to compare against. (Without this, the
            % first real call returns zero flow.)
            gray = toGray(frame);
            estimateFlow(opticFlow, gray); %#ok<NASGU>

            state = struct('opticFlow', opticFlow, 'noiseThresh', P.noiseThresh);
            varargout = {state};

        case 'update'
            frame  = varargin{1};
            state  = varargin{2};
            params = struct();
            if numel(varargin) >= 3 && ~isempty(varargin{3})
                params = varargin{3};
            end
            P = applyDefaults(params);

            % If NoiseThreshold changed in the GUI, rebuild the LK object
            % (it's a constructor-only parameter on opticalFlowLK).
            if abs(state.noiseThresh - P.noiseThresh) > 1e-9
                state.opticFlow = opticalFlowLK('NoiseThreshold', P.noiseThresh);
                state.noiseThresh = P.noiseThresh;
                % Prime once more so we don't get an empty first flow.
                estimateFlow(state.opticFlow, toGray(frame)); %#ok<NASGU>
            end

            gray = toGray(frame);
            flow = estimateFlow(state.opticFlow, gray);

            % --- Build moving-pixel mask + bboxes -----------------------
            mag  = sqrt(flow.Vx.^2 + flow.Vy.^2);
            mask = mag > P.motionThresh;
            if P.minBlobArea > 0
                mask = bwareaopen(mask, P.minBlobArea);
            end

            % Optional dilation to merge near-but-non-touching fragments
            % into a single blob. mergeRadius pixels of dilation = two
            % blobs up to 2 * mergeRadius apart will become connected.
            if P.mergeRadius > 0
                mask = imdilate(mask, strel('disk', P.mergeRadius));
            end

            stats = regionprops(mask, 'BoundingBox');
            bboxes = cell(1, numel(stats));
            for i = 1:numel(stats)
                bboxes{i} = stats(i).BoundingBox;
            end

            % The third return value is the opticalFlow OBJECT itself, so
            % the GUI can hand it to MATLAB's built-in plot(flow, ...) for
            % the quiver visualisation on axFilt.
            varargout = {state, bboxes, flow};

        otherwise
            error('sceneFlow:badMode', 'Unknown mode "%s"', mode);
    end
end


% ============================================================================
% Local helpers
% ============================================================================

function P = applyDefaults(P)
    if ~isfield(P,'noiseThresh'),  P.noiseThresh   = 0.009;  end
    if ~isfield(P,'motionThresh'), P.motionThresh  = 1.5;    end
    if ~isfield(P,'minBlobArea'),  P.minBlobArea   = 200;    end
    if ~isfield(P,'mergeRadius'),  P.mergeRadius   = 5;      end
end

function g = toGray(frame)
    if size(frame,3) == 3
        g = rgb2gray(frame);
    else
        g = frame;
    end
end
