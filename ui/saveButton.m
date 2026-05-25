function saveButton(fig)
% saveButton - Logic helper for the GUI Save Frame button.
%
% Captures whatever is currently rendered on the Tracked Objects axes
% (the frame with motion-cluster bboxes drawn on it) and writes it to a
% PNG chosen by the user. This is what they actually want to keep -
% the input frame alone is rarely interesting.
%
% The button itself is created inline in tracking_app.m. This file just
% contains the save action.

    d = fig.UserData;
    if isempty(d.tracking.currentFrameInput)
        uialert(fig, 'No frame loaded yet. Load a video first.', 'Save Frame');
        return;
    end

    % Capture the rendered axProc image (the bbox view). getframe pulls
    % the current pixel data straight off the axes, including everything
    % we drew on top.
    try
        framePix = getframe(d.h.axProc);
        imgOut = framePix.cdata;
    catch
        % Fallback: dump the raw preprocessed input if the axes screenshot
        % fails for any reason (e.g. axes not yet realised).
        imgOut = d.tracking.currentFrameInput;
    end

    defaultName = sprintf('frame_%s.png', ...
        char(datetime('now','Format','yyyyMMdd_HHmmss')));
    [file, path] = uiputfile('*.png', 'Save Frame As', defaultName);
    if isequal(file, 0), return; end

    try
        imwrite(imgOut, fullfile(path, file));
        uialert(fig, sprintf('Saved: %s', file), 'Saved', 'Icon', 'success');
    catch err
        uialert(fig, sprintf('Could not save:\n\n%s', err.message), ...
            'Save Frame Failed');
    end
end
