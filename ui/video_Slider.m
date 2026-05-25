function videoSlider(fig, action, value)
    if nargin < 3, value = 1; end
    d = fig.UserData;

    switch action
        case 'create'
            if isfield(d.h,'sliderVideo') && isvalid(d.h.sliderVideo)
                return;
            end
            cp = findControlPanel(fig);
            if isempty(cp), return; end
            sx = d.sx; sy = d.sy;
            PADDING = d.spacing.PADDING_PANEL;
            if isfield(d.h,'btnStop') && isvalid(d.h.btnStop)
                refY = d.h.btnStop.Position(2) - round(35*sy);
            else
                refY = round(600*sy);
            end
            sld = uislider(cp, ...
                'Limits',           [1 2], ...
                'Value',            1, ...
                'Position',         [PADDING, refY, round(240*sx), round(3*sy)], ...
                'FontSize',         10, ...
                'FontColor',        [0.8 0.8 0.8], ...
                'ValueChangingFcn', @(src,evt) videoSlider(fig,'seek',round(evt.Value)), ...
                'Visible',          'off');
            d.h.sliderVideo = sld;
            fig.UserData = d;

        case 'update'
            if ~isfield(d.h,'sliderVideo') || ~isvalid(d.h.sliderVideo)
                return;
            end
            total = d.tracking.videoReader.NumFrames;
            curr  = d.tracking.frameIndex;
            d.h.sliderVideo.Limits = [1 max(total,2)];
            d.h.sliderVideo.Value  = min(curr, total);
            fig.UserData = d;

        case 'seek'
            targetFrame = round(value);
            d.tracking.videoReader.CurrentTime = ...
                (targetFrame-1) / d.tracking.videoReader.FrameRate;
            d.tracking.frameIndex = targetFrame;
            fig.UserData = d;
    end
end

function cp = findControlPanel(fig)
    cp = [];
    kids = fig.Children;
    for k = 1:numel(kids)
        if isa(kids(k),'matlab.ui.container.Panel') && ...
                contains(kids(k).Title,'Controls')
            cp = kids(k);
            return;
        end
    end
end
