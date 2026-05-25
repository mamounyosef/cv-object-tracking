function saveButton(fig, action)
    if nargin < 2, action = 'create'; end

    switch action
        case 'create'
            d = fig.UserData;
            if isfield(d.h,'btnSave') && isvalid(d.h.btnSave)
                return;
            end
            cp = findControlPanel(fig);
            if isempty(cp), return; end
            sx = d.sx; sy = d.sy;
            PADDING = d.spacing.PADDING_PANEL;
            if isfield(d.h,'sliderVideo') && isvalid(d.h.sliderVideo)
                refY = d.h.sliderVideo.Position(2) - round(35*sy);
            else
                refY = round(560*sy);
            end
            btn = uibutton(cp, ...
                'Text',            '💾 Save Frame', ...
                'Position',        [PADDING, refY, round(244*sx), round(28*sy)], ...
                'FontSize',        11, ...
                'FontWeight',      'bold', ...
                'FontColor',       [1 1 1], ...
                'BackgroundColor', [0.15 0.35 0.55], ...
                'ButtonPushedFcn', @(~,~) saveButton(fig,'save'), ...
                'Visible',         'off');
            d.h.btnSave = btn;
            fig.UserData = d;

        case 'save'
            d = fig.UserData;
            if ~isfield(d.tracking,'currentFrameInput') || ...
                    isempty(d.tracking.currentFrameInput)
                uialert(fig, 'No frame to save. Play the video first.', 'Save Frame');
                return;
            end
            fname = sprintf('frame_%s.png', datestr(now,'yyyymmdd_HHMMSS'));
            [file, path] = uiputfile('*.png', 'Save Frame As', fname);
            if isequal(file,0), return; end
            imwrite(d.tracking.currentFrameInput, fullfile(path,file));
            uialert(fig, sprintf('Saved: %s', file), 'Saved ✓', 'Icon','success');
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
