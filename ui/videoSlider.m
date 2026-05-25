function videoSlider(fig, action, value)
% videoSlider - Logic helper for the GUI video position slider.
%
%   videoSlider(fig, 'update')         - push the current playback time
%                                        into the slider (called from the
%                                        playback loop every frame).
%   videoSlider(fig, 'seek', seconds)  - jump the video reader to the
%                                        given time in seconds (called
%                                        from the slider's ValueChangedFcn
%                                        on release).
%
% The slider value is measured in SECONDS, not frame indices, so it
% scales sensibly across videos with different frame rates.

    if nargin < 3, value = 0; end
    d = fig.UserData;

    switch action
        case 'update'
            if ~isfield(d.h,'sliderVideo') || ~isvalid(d.h.sliderVideo)
                return;
            end
            if isempty(d.tracking.videoReader), return; end
            fps = max(1, d.tracking.videoReader.FrameRate);
            total = max(0.1, double(d.tracking.videoReader.Duration));
            currSec = max(0, min(total, ...
                (d.tracking.frameIndex - 1) / fps));
            d.h.sliderVideo.Limits = [0 total];
            d.h.sliderVideo.Value  = currSec;
            if isfield(d.h,'lblVideoFrame') && isvalid(d.h.lblVideoFrame)
                d.h.lblVideoFrame.Text = sprintf( ...
                    'Time: %.2f s / %.2f s', currSec, total);
            end
            fig.UserData = d;

        case 'seek'
            if isempty(d.tracking.videoReader), return; end
            fps   = max(1, d.tracking.videoReader.FrameRate);
            total = double(d.tracking.videoReader.Duration);
            targetSec = max(0, min(total, value));
            d.tracking.videoReader.CurrentTime = targetSec;
            d.tracking.frameIndex = round(targetSec * fps) + 1;
            fig.UserData = d;
    end
end
