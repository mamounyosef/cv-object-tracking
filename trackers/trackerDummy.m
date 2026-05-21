function varargout = trackerDummy(mode, varargin)
% trackerDummy - Stub tracker that returns the initial bbox unchanged.
% Used by Member A to test the frame loop before real trackers exist.
% See TRACKER_CONTRACT.md for the interface.

    switch mode
        case 'init'
            frame = varargin{1}; %#ok<NASGU>
            bbox  = varargin{2};
            params = []; if numel(varargin) >= 3, params = varargin{3}; end %#ok<NASGU>

            state = struct('bbox', bbox);
            varargout = {state};

        case 'update'
            frame = varargin{1}; %#ok<NASGU>
            state = varargin{2};
            params = []; if numel(varargin) >= 3, params = varargin{3}; end %#ok<NASGU>

            bboxOut = state.bbox;
            vis = [];
            varargout = {state, bboxOut, vis};

        otherwise
            error('trackerDummy:badMode','Unknown mode "%s"',mode);
    end
end
