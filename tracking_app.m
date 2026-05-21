%% Close any previous instance
old = findall(0,'Type','figure','Name','CV Image Processing App');
if ~isempty(old), close(old); end

%% ── Figure ───────────────────────────────────────────────────────────────
ss = get(0,'ScreenSize');          % [1 1 screenW screenH]
sw = ss(3); sh = ss(4);
figW = min(1560, sw-40);
figH = min(960,  sh-60);
fig = uifigure('Name','CV Image Processing App', ...
               'Position',[20 30 figW figH], ...
               'Color',[0.12 0.12 0.14], ...
               'Visible','off');

% Scale factors relative to design size
sx = figW/1560;
sy = figH/960;

%% ── Spacing Constants (for consistent visual hierarchy) ─────────────────
% Outer margins
MARGIN_OUTER = round(8 * min(sx,sy));

% Padding inside panels
PADDING_PANEL = round(14 * sx);

% Vertical spacing between major sections
GAP_SECTION = round(50 * sy);

% Vertical spacing between related controls (label + dropdown/slider)
GAP_CONTROL_GROUP = round(38 * sy);

% Vertical spacing between label and its control
GAP_LABEL_TO_CONTROL = round(28 * sy);

% Horizontal spacing between axes
GAP_AXES = round(8 * sx);

% Button height
BTN_HEIGHT = round(34 * sy);

% Dropdown/control height
CONTROL_HEIGHT = round(30 * sy);

% Label height
LABEL_HEIGHT = round(20 * sy);

%% ── Control Panel ────────────────────────────────────────────────────────
cp = uipanel(fig,'Title','Controls', ...
    'Position',[MARGIN_OUTER MARGIN_OUTER round(272*sx) round(944*sy)], ...
    'BackgroundColor',[0.16 0.16 0.18], ...
    'ForegroundColor',[0.9 0.9 0.9], ...
    'FontSize',12,'FontWeight','bold', ...
    'Scrollable','on');     % allow scrolling when many preproc options expand

y = round(880 * sy);

btnLoad = uibutton(cp,'push', ...
    'Text','  Load Image', ...
    'Position',[PADDING_PANEL y round(244*sx) BTN_HEIGHT], ...
    'BackgroundColor',[0.20 0.55 0.90], ...
    'FontColor',[1 1 1],'FontWeight','bold','FontSize',13);
y = y - round(42*sy);

btnTemplate = uibutton(cp,'push', ...
    'Text','📂  Load Template', ...
    'Position',[PADDING_PANEL y round(244*sx) BTN_HEIGHT], ...
    'BackgroundColor',[0.20 0.68 0.42], ...
    'FontColor',[1 1 1],'FontWeight','bold','FontSize',13, ...
    'Visible','off');

btnROI = uibutton(cp,'push', ...
    'Text','+ Add ROI', ...
    'Position',[PADDING_PANEL y round(152*sx) BTN_HEIGHT], ...
    'BackgroundColor',[0.78 0.52 0.18], ...
    'FontColor',[1 1 1],'FontWeight','bold','FontSize',13, ...
    'Visible','off');

btnStep = uibutton(cp,'push', ...
    'Text','▶ Step', ...
    'Position',[PADDING_PANEL+round(160*sx) y round(84*sx) BTN_HEIGHT], ...
    'BackgroundColor',[0.28 0.62 0.38], ...
    'FontColor',[1 1 1],'FontWeight','bold','FontSize',13, ...
    'Visible','off');
y = y - round(42*sy);

btnClearROI = uibutton(cp,'push', ...
    'Text','✕ Clear ROIs', ...
    'Position',[PADDING_PANEL y round(244*sx) BTN_HEIGHT], ...
    'BackgroundColor',[0.55 0.30 0.30], ...
    'FontColor',[1 1 1],'FontWeight','bold','FontSize',12, ...
    'Visible','off');
y = y - round(42*sy);

btnPlay = uibutton(cp,'push', ...
    'Text','▶ Play', ...
    'Position',[PADDING_PANEL y round(76*sx) BTN_HEIGHT], ...
    'BackgroundColor',[0.18 0.58 0.36], ...
    'FontColor',[1 1 1],'FontWeight','bold','FontSize',12, ...
    'Visible','off');

btnPause = uibutton(cp,'push', ...
    'Text','⏸ Pause', ...
    'Position',[PADDING_PANEL+round(84*sx) y round(76*sx) BTN_HEIGHT], ...
    'BackgroundColor',[0.46 0.48 0.56], ...
    'FontColor',[1 1 1],'FontWeight','bold','FontSize',12, ...
    'Visible','off');

btnStop = uibutton(cp,'push', ...
    'Text','⏹ Stop', ...
    'Position',[PADDING_PANEL+round(168*sx) y round(76*sx) BTN_HEIGHT], ...
    'BackgroundColor',[0.66 0.32 0.30], ...
    'FontColor',[1 1 1],'FontWeight','bold','FontSize',12, ...
    'Visible','off');
y = y - GAP_SECTION;

makeLabel(cp,'Category',[PADDING_PANEL y round(244*sx) LABEL_HEIGHT]);
y = y - GAP_LABEL_TO_CONTROL;
ddCat = uidropdown(cp,'Items',{'Enhancement','Spatial Filtering', ...
        'Frequency Filtering','Color Space', ...
        'Pyramids','Template Matching','Filter Banks','Edge Detection','Corner Detection', ...
        'Blob Detection','HoG','Hough Transform','RANSAC','Stereo Vision','Object Tracking'}, ...
        'Position',[PADDING_PANEL y round(244*sx) CONTROL_HEIGHT]);
y = y - GAP_CONTROL_GROUP;

makeLabel(cp,'Operation',[PADDING_PANEL y round(244*sx) LABEL_HEIGHT]);
y = y - GAP_LABEL_TO_CONTROL;
ddOp = uidropdown(cp,'Items',{'Brightness','Histogram Equalization'}, ...
       'Position',[PADDING_PANEL y round(244*sx) CONTROL_HEIGHT]);
y = y - GAP_SECTION;

lblParam = makeLabel(cp,'Parameter: 0.00',[PADDING_PANEL y round(244*sx) LABEL_HEIGHT]);
y = y - GAP_LABEL_TO_CONTROL;
slParam  = uislider(cp,'Limits',[-1 1],'Value',0,'Position',[PADDING_PANEL y round(244*sx) 3], ...
           'MajorTicks',[],'MinorTicks',[]);
y = y - GAP_SECTION - round(15*sy);  % Extra space before Butterworth order sliders

lblLP = makeLabel(cp,'Butterworth LP Order n: 2',[PADDING_PANEL y round(244*sx) LABEL_HEIGHT]);
lblLP.Visible='off';
y = y - GAP_LABEL_TO_CONTROL;
slLP = uislider(cp,'Limits',[1 10],'Value',2,'Position',[PADDING_PANEL y round(244*sx) 3], ...
       'MajorTicks',[],'MinorTicks',[],'Visible','off');
y = y - GAP_SECTION;

lblHP = makeLabel(cp,'Butterworth HP Order n: 2',[PADDING_PANEL y round(244*sx) LABEL_HEIGHT]);
lblHP.Visible='off';
y = y - GAP_LABEL_TO_CONTROL;
slHP = uislider(cp,'Limits',[1 10],'Value',2,'Position',[PADDING_PANEL y round(244*sx) 3], ...
       'MajorTicks',[],'MinorTicks',[],'Visible','off');
y = y - GAP_SECTION;

% ── Pre-Processing section ────────────────────────────────────────────────
lblPreprocHeader = uilabel(cp,'Position',[PADDING_PANEL y round(244*sx) LABEL_HEIGHT], ...
    'Text','─── Pre-Processing ───', ...
    'FontSize',10,'FontColor',[0.6 0.75 0.9],'HorizontalAlignment','center');
y = y - round(28*sy);

chkForceGray = uicheckbox(cp, ...
    'Text','Force Grayscale', ...
    'Position',[PADDING_PANEL y round(244*sx) round(22*sy)], ...
    'FontColor',[0.9 0.9 0.9],'FontSize',11,'Value',false);
y = y - round(28*sy);

chkHistEq = uicheckbox(cp, ...
    'Text','Histogram Equalization', ...
    'Position',[PADDING_PANEL y round(244*sx) round(22*sy)], ...
    'FontColor',[0.9 0.9 0.9],'FontSize',11,'Value',false);
y = y - round(32*sy);

chkBoxFilt = uicheckbox(cp, ...
    'Text','Box Filter', ...
    'Position',[PADDING_PANEL y round(244*sx) round(22*sy)], ...
    'FontColor',[0.9 0.9 0.9],'FontSize',11,'Value',false);
y = y - round(28*sy);

lblBoxSize = uilabel(cp,'Position',[PADDING_PANEL y round(244*sx) LABEL_HEIGHT], ...
    'Text','Kernel: 3x3', ...
    'FontSize',10,'FontColor',[0.75 0.85 0.75],'Visible','off');
y = y - GAP_LABEL_TO_CONTROL;
slBoxSize = uislider(cp,'Limits',[1 15],'Value',3, ...
    'Position',[PADDING_PANEL y round(244*sx) 3], ...
    'MajorTicks',[1 3 5 7 9 11 13 15],'MinorTicks',[],'Visible','off');
y = y - round(22*sy);

chkGauss = uicheckbox(cp, ...
    'Text','Gaussian Filter', ...
    'Position',[PADDING_PANEL y round(244*sx) round(22*sy)], ...
    'FontColor',[0.9 0.9 0.9],'FontSize',11,'Value',false);
y = y - round(26*sy);

lblGaussSigma = uilabel(cp,'Position',[PADDING_PANEL y round(244*sx) LABEL_HEIGHT], ...
    'Text','Sigma: 1.0', ...
    'FontSize',10,'FontColor',[0.75 0.85 0.75],'Visible','off');
y = y - GAP_LABEL_TO_CONTROL;
slGaussSigma = uislider(cp,'Limits',[0.5 5],'Value',1, ...
    'Position',[PADDING_PANEL y round(244*sx) 3], ...
    'MajorTicks',[0.5 1 2 3 4 5],'MinorTicks',[],'Visible','off');
y = y - round(22*sy);

chkSobelH = uicheckbox(cp, ...
    'Text','Sobel H (preprocess)', ...
    'Position',[PADDING_PANEL y round(244*sx) round(22*sy)], ...
    'FontColor',[0.9 0.9 0.9],'FontSize',11,'Value',false);
y = y - round(26*sy);

chkSobelV = uicheckbox(cp, ...
    'Text','Sobel V (preprocess)', ...
    'Position',[PADDING_PANEL y round(244*sx) round(22*sy)], ...
    'FontColor',[0.9 0.9 0.9],'FontSize',11,'Value',false);

%% ── Image axes (top strip) ───────────────────────────────────────────────
% Heights chosen so axes sit above kp (top=328 at sy=1) AND axis labels fit
% under figH=960. Widths chosen so 3-box layout fits within figW=1560.
axTop=round(340*sy); axH=round(590*sy); axW=round(415*sx);
x1=round(290*sx); x2=x1+axW+GAP_AXES; x3=x2+axW+GAP_AXES;

lblAxOrig = makeAxLabel(fig,'Original Image', [x1 axTop+axH+round(4*sy) axW round(22*sy)]);
lblAxFilt = makeAxLabel(fig,'Filter / H(u,v)',[x2 axTop+axH+round(4*sy) axW round(22*sy)]);
lblAxProc = makeAxLabel(fig,'Processed Image',[x3 axTop+axH+round(4*sy) axW round(22*sy)]);

axOrig = uiaxes(fig,'Position',[x1 axTop axW axH]); styleAxes(axOrig);
axFilt = uiaxes(fig,'Position',[x2 axTop axW axH]); styleAxes(axFilt);
axProc = uiaxes(fig,'Position',[x3 axTop axW axH]); styleAxes(axProc);
% NOTE: initial position stacked on axProc (was x4 > figW, off-screen).
% applyProc repositions all four axes when Template Matching is active.
lblAxBBox = makeAxLabel(fig,'Match Location',[x3 axTop+axH+round(4*sy) axW round(22*sy)]);
axBBox = uiaxes(fig,'Position',[x3 axTop axW axH]); styleAxes(axBBox);
axBBox.Visible = 'off'; lblAxBBox.Visible = 'off';

%% ── Kernel / Mask panel (bottom strip) ───────────────────────────────────
% Height reduced from 380 to 320 so image axes above can clear it without
% being covered (kp drawn last → previously covered bottom 38px of axes).
kp = uipanel(fig, ...
    'Title','  Kernel / Filter Mask Visualisation  (Gonzalez & Woods reference)', ...
    'Position',[round(290*sx) MARGIN_OUTER round(1258*sx) round(320*sy)], ...
    'BackgroundColor',[0.11 0.11 0.14], ...
    'ForegroundColor',[0.85 0.85 0.85], ...
    'FontSize',11,'FontWeight','bold');

% Description box - positioned below panel title, above visualizations
descPanel = uipanel(kp,'Position',[PADDING_PANEL round(245*sy) round(1230*sx) round(40*sy)], ...
    'BackgroundColor',[0.14 0.16 0.20], ...
    'BorderType','line','HighlightColor',[0.25 0.30 0.40]);

lblDesc = uilabel(descPanel,'Position',[8 2 round(1214*sx) round(36*sy)], ...
    'Text','Select a category and operation to see the kernel or mask.', ...
    'FontSize',11,'FontColor',[0.7 0.85 1.0],'FontAngle','italic', ...
    'WordWrap','on','VerticalAlignment','top');

% Kernel visualizations - positioned below description box
axKern = uiaxes(kp,'Position',[PADDING_PANEL LABEL_HEIGHT round(420*sx) round(220*sy)], ...
    'Color',[0.08 0.08 0.10],'XColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5], ...
    'FontSize',10,'Box','on');

txtKern = uitextarea(kp,'Position',[round(450*sx) LABEL_HEIGHT round(790*sx) round(220*sy)], ...
    'Value',{'Kernel / mask will appear here.'}, ...
    'FontName','Courier New','FontSize',13, ...
    'FontColor',[0.85 1.0 0.85],'BackgroundColor',[0.08 0.10 0.08], ...
    'Editable','off');

%% ── Store all handles + state in figure UserData ─────────────────────────
h = struct( ...
    'fig',fig, 'ddCat',ddCat, 'ddOp',ddOp, ...
    'slParam',slParam, 'lblParam',lblParam, ...
    'slLP',slLP, 'lblLP',lblLP, ...
    'slHP',slHP, 'lblHP',lblHP, ...
    'btnLoad',btnLoad, 'btnTemplate',btnTemplate, ...
    'btnROI',btnROI, 'btnClearROI',btnClearROI, 'btnStep',btnStep, ...
    'btnPlay',btnPlay, 'btnPause',btnPause, 'btnStop',btnStop, ...
    'chkForceGray',chkForceGray, ...
    'chkHistEq',chkHistEq, ...
    'chkBoxFilt',chkBoxFilt, 'lblBoxSize',lblBoxSize, 'slBoxSize',slBoxSize, ...
    'chkGauss',chkGauss, 'lblGaussSigma',lblGaussSigma, 'slGaussSigma',slGaussSigma, ...
    'chkSobelH',chkSobelH, 'chkSobelV',chkSobelV, 'lblPreprocHeader',lblPreprocHeader, ...
    'axOrig',axOrig, 'lblAxOrig',lblAxOrig, ...
    'axFilt',axFilt, 'lblAxFilt',lblAxFilt, ...
    'axProc',axProc, 'lblAxProc',lblAxProc, ...
    'axBBox',axBBox, 'lblAxBBox',lblAxBBox, ...
    'kp',kp, 'axKern',axKern, 'txtKern',txtKern, 'lblDesc',lblDesc);

% Save baseline Y positions of preprocessing block for dynamic relayout
% (used when Butterworth sliders show/hide so the gap collapses).
h.preprocCtrls = {lblPreprocHeader, chkForceGray, chkHistEq, chkBoxFilt, ...
                  lblBoxSize, slBoxSize, chkGauss, lblGaussSigma, slGaussSigma, ...
                  chkSobelH, chkSobelV};
h.preprocBaseY = zeros(1, numel(h.preprocCtrls));
for ii = 1:numel(h.preprocCtrls)
    h.preprocBaseY(ii) = h.preprocCtrls{ii}.Position(2);
end
% Vertical space the two Butterworth sliders consume when visible.
% When both hidden, shift preproc UP by this amount.
h.bwReservedY = round(2*(GAP_SECTION + GAP_LABEL_TO_CONTROL));

% Store spacing constants for use in callbacks
spacing = struct('GAP_AXES', GAP_AXES, 'PADDING_PANEL', PADDING_PANEL);
tracking = struct( ...
    'videoReader',[], ...
    'videoPath','', ...
    'currentFrameRaw',[], ...
    'currentFrameInput',[], ...
    'frameIndex',0, ...
    'initialBBoxes',{{}}, ...   % cell array of [x y w h] (one per ROI)
    'currentBBoxes',{{}}, ...   % cell array of [x y w h] (one per active tracker; [] if lost)
    'trackerStates',{{}}, ...   % cell array of state structs (one per tracker)
    'initialized',false, ...    % true iff at least one tracker initialized
    'allLost',false, ...        % true iff every tracker has lost its target
    'isPlaying',false, ...
    'timer',[], ...
    'lastVis',[]);
fig.UserData = struct('h',h, 'origImg',[], 'procImg',[], 'templateImg',[], ...
    'tracking',tracking, 'sx',sx, 'sy',sy, 'spacing',spacing);

%% ── Wire up callbacks ────────────────────────────────────────────────────
btnLoad.ButtonPushedFcn     = @(~,~) cb_Load(fig);
btnTemplate.ButtonPushedFcn = @(~,~) cb_LoadTemplate(fig);
btnROI.ButtonPushedFcn      = @(~,~) cb_SelectTrackingROI(fig);
btnClearROI.ButtonPushedFcn = @(~,~) cb_ClearROIs(fig);
btnStep.ButtonPushedFcn     = @(~,~) cb_StepTracking(fig);
btnPlay.ButtonPushedFcn     = @(~,~) cb_PlayTracking(fig);
btnPause.ButtonPushedFcn    = @(~,~) cb_PauseTracking(fig);
btnStop.ButtonPushedFcn     = @(~,~) cb_StopTracking(fig);
ddCat.ValueChangedFcn    = @(~,~) cb_CatChanged(fig);
ddOp.ValueChangedFcn     = @(~,~) cb_OpChanged(fig);
slParam.ValueChangingFcn = @(~,e) cb_ParamChanging(fig,e);
slParam.ValueChangedFcn  = @(~,e) cb_ParamReleased(fig,e);
slLP.ValueChangingFcn    = @(~,e) cb_LPChanging(fig,e);
slLP.ValueChangedFcn     = @(~,e) cb_LPReleased(fig,e);
slHP.ValueChangingFcn    = @(~,e) cb_HPChanging(fig,e);
slHP.ValueChangedFcn     = @(~,e) cb_HPReleased(fig,e);
chkForceGray.ValueChangedFcn   = @(~,~) applyProc(fig);
chkHistEq.ValueChangedFcn      = @(~,~) applyProc(fig);
chkBoxFilt.ValueChangedFcn     = @(~,~) cb_BoxFiltToggle(fig);
slBoxSize.ValueChangedFcn      = @(~,~) cb_BoxSizeReleased(fig);
chkGauss.ValueChangedFcn       = @(~,~) cb_GaussToggle(fig);
slGaussSigma.ValueChangedFcn   = @(~,~) cb_GaussSigmaReleased(fig);
chkSobelH.ValueChangedFcn      = @(~,~) applyProc(fig);
chkSobelV.ValueChangedFcn      = @(~,~) applyProc(fig);
fig.CloseRequestFcn = @(src,~) cb_CloseApp(src);

%% ── Init and show ────────────────────────────────────────────────────────
cb_CatChanged(fig);
fig.Visible = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CALLBACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cb_Load(fig)
    d = fig.UserData;
    if strcmp(d.h.ddCat.Value,'Object Tracking')
        cb_LoadTrackingVideo(fig);
        return;
    end

    [f,p] = uigetfile({'*.jpg;*.png;*.bmp;*.tif','Images'});
    if isequal(f,0), return; end
    d.origImg = imread(fullfile(p,f));
    fig.UserData = d;
    applyProc(fig);
end

function cb_LoadTrackingVideo(fig)
    deleteTrackingTimer(fig);
    [f,p] = uigetfile({'*.mp4;*.avi;*.mov;*.m4v','Video Files (*.mp4, *.avi, *.mov, *.m4v)'});
    if isequal(f,0), return; end

    videoPath = fullfile(p,f);
    try
        videoReader = VideoReader(videoPath);
    catch err
        uialert(fig, sprintf('Could not open the selected video.\n\n%s', err.message), ...
            'Video Load Failed');
        return;
    end

    try
        if ~hasFrame(videoReader)
            uialert(fig, 'The selected video has no readable frames.', ...
                'Video Load Failed');
            return;
        end
        firstFrame = readFrame(videoReader);
        if isempty(firstFrame)
            uialert(fig, 'The selected video has no readable frames.', ...
                'Video Load Failed');
            return;
        end
    catch err
        uialert(fig, sprintf('Could not read the first video frame.\n\n%s', err.message), ...
            'Video Load Failed');
        return;
    end

    d = fig.UserData;
    frameInput = preProcess(firstFrame, d.h);
    d.tracking.videoReader = videoReader;
    d.tracking.videoPath = videoPath;
    d.tracking.currentFrameRaw = firstFrame;
    d.tracking.currentFrameInput = frameInput;
    d.tracking.frameIndex = 1;
    d.tracking.initialBBoxes = {};
    d.tracking.currentBBoxes = {};
    d.tracking.trackerStates = {};
    d.tracking.initialized = false;
    d.tracking.allLost = false;
    d.tracking.isPlaying = false;
    d.tracking.lastVis = [];
    fig.UserData = d;

    renderTrackingPreview(fig);
end

function cb_LoadTemplate(fig)
    [f,p] = uigetfile({'*.jpg;*.png;*.bmp;*.tif','Images'});
    if isequal(f,0), return; end
    d = fig.UserData;
    d.templateImg = imread(fullfile(p,f));
    fig.UserData = d;
    applyProc(fig);
end

function cb_SelectTrackingROI(fig)
    d = fig.UserData;
    if ~strcmp(d.h.ddCat.Value,'Object Tracking')
        return;
    end
    if isempty(d.tracking.currentFrameInput)
        uialert(fig, 'Load a tracking video before selecting an ROI.', ...
            'ROI Selection');
        return;
    end

    % Render the first frame with any already-initialized ROIs overlaid, so
    % the user can see what is already being tracked while drawing the next box.
    renderTrackingInitialization(fig);

    try
        roi = drawrectangle(d.h.axOrig);
        % drawrectangle returns once the user finishes the initial click-drag
        % (no double-click commit needed). If the user just clicked without
        % a real drag, treat it as cancelled.
        if ~isvalid(roi) || isempty(roi.Position) || ...
                roi.Position(3) < 1 || roi.Position(4) < 1
            if isvalid(roi), delete(roi); end
            return;
        end
        bbox = clampTrackingBBox(roi.Position, size(d.tracking.currentFrameInput));
        delete(roi);
    catch err
        uialert(fig, sprintf('Could not select the ROI.\n\n%s', err.message), ...
            'ROI Selection Failed');
        return;
    end

    if ~isValidTrackingBBox(bbox)
        uialert(fig, 'Select an ROI at least 5 pixels wide and 5 pixels high inside the frame.', ...
            'Invalid ROI');
        return;
    end

    % Conflict check: reject if the new ROI overlaps an existing one too much.
    for i = 1:numel(d.tracking.initialBBoxes)
        if bboxIoU(bbox, d.tracking.initialBBoxes{i}) > 0.5
            uialert(fig, sprintf(['The new ROI overlaps tracker %d by more ' ...
                'than 50%%. Pick a non-overlapping region.'], i), ...
                'ROI Conflict');
            return;
        end
    end

    trackingInitFromROI(fig, bbox);
end

function cb_ClearROIs(fig)
    d = fig.UserData;
    if ~strcmp(d.h.ddCat.Value,'Object Tracking')
        return;
    end
    stopTrackingTimer(fig);
    d.tracking.initialBBoxes = {};
    d.tracking.currentBBoxes = {};
    d.tracking.trackerStates = {};
    d.tracking.initialized = false;
    d.tracking.allLost = false;
    d.tracking.isPlaying = false;
    d.tracking.lastVis = [];
    fig.UserData = d;
    resetTrackingToFirstFrame(fig);
end

function trackingInitFromROI(fig, bbox)
    d = fig.UserData;
    frameInput = d.tracking.currentFrameInput;
    if isempty(frameInput), return; end

    params = getTrackingParams(fig);
    try
        ensureKLTTrackerOnPath();
        state = trackerKLT('init', frameInput, bbox, params);
        if ~isfield(state,'points') || size(state.points,1) < 3
            error('tracking_app:tooFewKLTPoints', ...
                'The ROI has too few KLT points. Select a more textured region.');
        end
    catch err
        uialert(fig, sprintf('Could not initialize the KLT tracker.\n\n%s', err.message), ...
            'KLT Initialization Failed');
        return;
    end

    d.tracking.initialBBoxes{end+1} = bbox;
    d.tracking.currentBBoxes{end+1} = bbox;
    d.tracking.trackerStates{end+1} = state;
    d.tracking.initialized = true;
    d.tracking.allLost = false;
    fig.UserData = d;

    renderTrackingInitialization(fig);
end

function cb_StepTracking(fig)
    d = fig.UserData;
    if ~strcmp(d.h.ddCat.Value,'Object Tracking')
        return;
    end
    if isempty(d.tracking.videoReader)
        uialert(fig, 'Load a tracking video before stepping frames.', ...
            'Tracking Step');
        return;
    end
    if ~d.tracking.initialized || isempty(d.tracking.trackerStates)
        uialert(fig, 'Select a valid ROI before stepping KLT tracking.', ...
            'Tracking Step');
        return;
    end

    trackingStep(fig);
end

function cb_PlayTracking(fig)
    d = fig.UserData;
    if ~strcmp(d.h.ddCat.Value,'Object Tracking')
        return;
    end
    if isempty(d.tracking.videoReader)
        uialert(fig, 'Load a tracking video before playback.', ...
            'Tracking Playback');
        return;
    end
    if ~d.tracking.initialized || isempty(d.tracking.trackerStates)
        uialert(fig, 'Select a valid ROI before playing KLT tracking.', ...
            'Tracking Playback');
        return;
    end
    if d.tracking.allLost
        uialert(fig, 'All tracks are lost. Stop and select new ROIs before playback.', ...
            'Tracking Playback');
        return;
    end
    if ~hasFrame(d.tracking.videoReader)
        d.h.axProc.Title.String = 'End of Video';
        d.tracking.isPlaying = false;
        fig.UserData = d;
        return;
    end

    timerObj = d.tracking.timer;
    if isempty(timerObj) || ~isvalid(timerObj)
        timerObj = timer( ...
            'ExecutionMode','fixedSpacing', ...
            'Period',trackingTimerPeriod(d.tracking.videoReader), ...
            'TimerFcn',@(~,~) trackingTimerTick(fig));
        d.tracking.timer = timerObj;
    end
    d.tracking.isPlaying = true;
    fig.UserData = d;

    if strcmp(timerObj.Running,'off')
        start(timerObj);
    end
end

function cb_PauseTracking(fig)
    if ~isvalid(fig), return; end
    stopTrackingTimer(fig);
end

function cb_StopTracking(fig)
    if ~isvalid(fig), return; end
    deleteTrackingTimer(fig);
    resetTrackingToFirstFrame(fig);
end

function trackingStep(fig)
    if ~isvalid(fig), return; end
    d = fig.UserData;
    if ~strcmp(d.h.ddCat.Value,'Object Tracking')
        return;
    end
    videoReader = d.tracking.videoReader;
    if isempty(videoReader), return; end

    try
        if ~hasFrame(videoReader)
            d.h.axProc.Title.String = 'End of Video';
            d.tracking.isPlaying = false;
            fig.UserData = d;
            stopTrackingTimer(fig);
            return;
        end
        frameRaw = readFrame(videoReader);
        if isempty(frameRaw)
            d.h.axProc.Title.String = 'End of Video';
            d.tracking.isPlaying = false;
            fig.UserData = d;
            stopTrackingTimer(fig);
            return;
        end
    catch err
        stopTrackingTimer(fig);
        uialert(fig, sprintf('Could not read the next video frame.\n\n%s', err.message), ...
            'Tracking Step Failed');
        return;
    end

    frameInput = preProcess(frameRaw, d.h);
    params = getTrackingParams(fig);

    nTrackers = numel(d.tracking.trackerStates);
    ensureKLTTrackerOnPath();
    for i = 1:nTrackers
        try
            [state_i, bbox_i, ~] = trackerKLT('update', frameInput, ...
                d.tracking.trackerStates{i}, params);
        catch
            % Isolate per-tracker failure: mark this one lost and keep going
            % so other tracks are not killed by one tracker's exception.
            state_i = d.tracking.trackerStates{i};
            if isstruct(state_i), state_i.lost = true; end
            bbox_i  = [];
        end
        d.tracking.trackerStates{i} = state_i;
        d.tracking.currentBBoxes{i} = bbox_i;   % [] if lost
    end

    d.tracking.frameIndex = d.tracking.frameIndex + 1;
    d.tracking.currentFrameRaw = frameRaw;
    d.tracking.currentFrameInput = frameInput;
    d.tracking.allLost = all(cellfun(@isempty, d.tracking.currentBBoxes));
    fig.UserData = d;

    renderTrackingFrame(fig, frameInput);
    if d.tracking.allLost
        stopTrackingTimer(fig);
    end
end

function params = getTrackingParams(~)
    % TODO: expose KLT initialization/update parameters in the tracking UI.
    params = struct();
end

function trackingTimerTick(fig)
    if ~isvalid(fig)
        return;
    end
    d = fig.UserData;
    if ~strcmp(d.h.ddCat.Value,'Object Tracking') || ~d.tracking.isPlaying
        stopTrackingTimer(fig);
        return;
    end
    trackingStep(fig);
end

function period = trackingTimerPeriod(videoReader)
    period = 0.05;
    if isprop(videoReader,'FrameRate') && isfinite(videoReader.FrameRate) && videoReader.FrameRate > 0
        period = max(0.02, min(0.20, 1/videoReader.FrameRate));
    end
end

function stopTrackingTimer(fig)
    if ~isvalid(fig), return; end
    d = fig.UserData;
    timerObj = d.tracking.timer;
    if ~isempty(timerObj) && isvalid(timerObj) && strcmp(timerObj.Running,'on')
        stop(timerObj);
    end
    d.tracking.isPlaying = false;
    fig.UserData = d;
end

function deleteTrackingTimer(fig)
    if ~isvalid(fig), return; end
    d = fig.UserData;
    timerObj = d.tracking.timer;
    if ~isempty(timerObj) && isvalid(timerObj)
        if strcmp(timerObj.Running,'on')
            stop(timerObj);
        end
        delete(timerObj);
    end
    d.tracking.timer = [];
    d.tracking.isPlaying = false;
    fig.UserData = d;
end

function resetTrackingToFirstFrame(fig)
    d = fig.UserData;
    videoPath = d.tracking.videoPath;
    if isempty(videoPath)
        return;
    end

    try
        videoReader = VideoReader(videoPath);
        if ~hasFrame(videoReader)
            error('tracking_app:noResetFrame','The video has no readable frames.');
        end
        firstFrame = readFrame(videoReader);
        if isempty(firstFrame)
            error('tracking_app:noResetFrame','The video has no readable frames.');
        end
    catch err
        uialert(fig, sprintf('Could not reset the tracking video.\n\n%s', err.message), ...
            'Tracking Reset Failed');
        return;
    end

    d.tracking.videoReader = videoReader;
    d.tracking.currentFrameRaw = firstFrame;
    d.tracking.currentFrameInput = preProcess(firstFrame, d.h);
    d.tracking.frameIndex = 1;
    d.tracking.initialBBoxes = {};
    d.tracking.currentBBoxes = {};
    d.tracking.trackerStates = {};
    d.tracking.initialized = false;
    d.tracking.allLost = false;
    d.tracking.isPlaying = false;
    d.tracking.timer = [];
    d.tracking.lastVis = [];
    fig.UserData = d;

    renderTrackingPreview(fig);
end

function renderTrackingPreview(fig)
    d = fig.UserData;
    if isempty(d.tracking.currentFrameInput), return; end

    d.h.lblAxOrig.Text = 'Tracking Input';
    d.h.lblAxFilt.Text = 'KLT Points';
    d.h.lblAxProc.Text = 'Tracked Object';

    imshow(d.tracking.currentFrameInput, 'Parent', d.h.axOrig);
    clearTrackingPreviewAxis(d.h.axFilt, 'Select ROI to initialize KLT points.');
    clearTrackingPreviewAxis(d.h.axProc, 'Tracked output appears after ROI initialization.');
end

function renderTrackingInitialization(fig)
    d = fig.UserData;
    frameInput = d.tracking.currentFrameInput;
    if isempty(frameInput), return; end

    d.h.lblAxOrig.Text = 'Tracking Input';
    d.h.lblAxFilt.Text = 'KLT Points';
    d.h.lblAxProc.Text = 'Tracked Objects';

    imshow(frameInput, 'Parent', d.h.axOrig);

    vis = drawAllKLTVis(frameInput, d.tracking.trackerStates, d.tracking.currentBBoxes);
    if isempty(vis)
        imshow(frameInput, 'Parent', d.h.axFilt);
    else
        imshow(vis, 'Parent', d.h.axFilt);
        d.tracking.lastVis = vis;
    end

    imshow(drawTrackingBBoxes(frameInput, d.tracking.currentBBoxes), ...
        'Parent', d.h.axProc);
    fig.UserData = d;
end

function renderTrackingFrame(fig, frameInput)
    d = fig.UserData;
    d.h.lblAxOrig.Text = 'Tracking Input';
    d.h.lblAxFilt.Text = 'KLT Points';
    d.h.lblAxProc.Text = 'Tracked Objects';

    imshow(frameInput, 'Parent', d.h.axOrig);

    vis = drawAllKLTVis(frameInput, d.tracking.trackerStates, d.tracking.currentBBoxes);
    if isempty(vis)
        imshow(frameInput, 'Parent', d.h.axFilt);
    else
        imshow(vis, 'Parent', d.h.axFilt);
        d.tracking.lastVis = vis;
    end

    imshow(drawTrackingBBoxes(frameInput, d.tracking.currentBBoxes), ...
        'Parent', d.h.axProc);

    if d.tracking.allLost
        d.h.axProc.Title.String = 'All Tracks Lost';
        text(d.h.axProc, 0.5, 0.5, 'All Tracks Lost', ...
            'Units','normalized', ...
            'Color',[1 0.45 0.25], ...
            'FontSize',14, ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle');
    else
        nLost = sum(cellfun(@isempty, d.tracking.currentBBoxes));
        if nLost > 0
            d.h.axProc.Title.String = sprintf('Tracked Objects (%d lost)', nLost);
        else
            d.h.axProc.Title.String = 'Tracked Objects';
        end
    end
    fig.UserData = d;
end

function out = drawTrackingBBoxes(frame, bboxes)
    out = toRGBFrame(frame);
    if isempty(bboxes)
        return;
    end
    for i = 1:numel(bboxes)
        b = bboxes{i};
        if isempty(b), continue; end
        c = trackColor(i);
        out = insertShape(out, 'Rectangle', b, 'Color', c, 'LineWidth', 2);
        % ID label in the top-left corner of the box
        out = insertText(out, [b(1), b(2)], sprintf(' %d ', i), ...
            'FontSize', 14, 'BoxColor', c, 'BoxOpacity', 0.85, ...
            'TextColor', [0 0 0]);
    end
end

function clearTrackingPreviewAxis(ax, msg)
    cla(ax);
    text(ax, 0.5, 0.5, msg, ...
        'Units','normalized', ...
        'Color',[0.75 0.85 1.0], ...
        'FontSize',12, ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle');
end

function bbox = clampTrackingBBox(pos, frameSize)
    bbox = [];
    if numel(pos) ~= 4 || any(~isfinite(pos))
        return;
    end

    H = frameSize(1);
    W = frameSize(2);
    x1 = max(1, pos(1));
    y1 = max(1, pos(2));
    x2 = min(W, pos(1) + pos(3));
    y2 = min(H, pos(2) + pos(4));
    bbox = [x1 y1 x2-x1 y2-y1];
end

function tf = isValidTrackingBBox(bbox)
    tf = numel(bbox) == 4 && all(isfinite(bbox)) && bbox(3) >= 5 && bbox(4) >= 5;
end

function out = drawAllKLTVis(frame, states, bboxes)
% Overlay all tracker point clouds (per-track color) plus their bboxes.
    if isempty(states)
        out = [];
        return;
    end

    out = toRGBFrame(frame);
    anyDrawn = false;
    for i = 1:numel(states)
        s = states{i};
        c = trackColor(i);
        if ~isempty(s) && isfield(s,'points') && ~isempty(s.points)
            out = insertMarker(out, s.points, '+', 'Color', c, 'Size', 5);
            anyDrawn = true;
        end
        if i <= numel(bboxes) && ~isempty(bboxes{i})
            out = insertShape(out, 'Rectangle', bboxes{i}, ...
                'Color', c, 'LineWidth', 2);
            anyDrawn = true;
        end
    end
    if ~anyDrawn
        out = [];
    end
end

function iou = bboxIoU(a, b)
% Intersection-over-union between two [x y w h] boxes.
    if isempty(a) || isempty(b), iou = 0; return; end
    ax2 = a(1) + a(3); ay2 = a(2) + a(4);
    bx2 = b(1) + b(3); by2 = b(2) + b(4);
    ix1 = max(a(1), b(1)); iy1 = max(a(2), b(2));
    ix2 = min(ax2, bx2);   iy2 = min(ay2, by2);
    iw = max(0, ix2 - ix1);
    ih = max(0, iy2 - iy1);
    inter = iw * ih;
    uni = a(3) * a(4) + b(3) * b(4) - inter;
    if uni <= 0, iou = 0; else, iou = inter / uni; end
end

function c = trackColor(id)
% Stable palette so each tracker keeps its color across frames.
    palette = uint8([ ...
        255 230   0;   % yellow
         30 200 255;   % cyan
        255  90 130;   % pink
         60 255  80;   % green
        255 150  50;   % orange
        180  90 255;   % purple
        255 255 255;   % white
        100 255 200]); % aqua
    c = palette(mod(id-1, size(palette,1)) + 1, :);
end

function out = toRGBFrame(frame)
    if size(frame,3) == 1
        out = repmat(frame, 1, 1, 3);
    else
        out = frame;
    end
end

function ensureKLTTrackerOnPath()
    if ~isempty(which('trackerKLT'))
        return;
    end
    appDir = fileparts(mfilename('fullpath'));
    if isempty(appDir)
        appDir = fileparts(which('tracking_app'));
    end
    trackerDir = fullfile(appDir, 'trackers');
    if exist(fullfile(trackerDir, 'trackerKLT.m'), 'file')
        addpath(trackerDir);
    end
    if isempty(which('trackerKLT'))
        error('tracking_app:kltPath', 'Could not find trackers/trackerKLT.m.');
    end
end

function cb_CatChanged(fig)
    d = fig.UserData;
    if ~strcmp(d.h.ddCat.Value,'Object Tracking')
        deleteTrackingTimer(fig);
        d = fig.UserData;
    end
    switch d.h.ddCat.Value
        case 'Enhancement'
            d.h.ddOp.Items = {'Brightness','Histogram Equalization'};
        case 'Spatial Filtering'
            d.h.ddOp.Items = {'Box Filter','Weighted Average','Median Filter', ...
                'Laplacian 1st','Laplacian 2nd','Boosting','Sobel H','Sobel V','Prewitt'};
        case 'Frequency Filtering'
            d.h.ddOp.Items = {'Ideal LP','Butterworth LP','Gaussian LP', ...
                'Ideal HP','Butterworth HP','Gaussian HP'};
        case 'Color Space'
            d.h.ddOp.Items = {'RGB to HSI','RGB to Lab','RGB to YCbCr'};
        case 'Pyramids'
            d.h.ddOp.Items = {'Gaussian Reduce','Gaussian Expand','Laplacian Level'};
        case 'Template Matching'
            d.h.ddOp.Items = {'Correlation','Zero-mean Correlation', ...
                              'Sum Square Difference','Normalized Cross Correlation'};
        case 'Filter Banks'
            d.h.ddOp.Items = {'DoG Bank','Gabor Bank'};
        case 'Edge Detection'
            d.h.ddOp.Items = {'Sobel (edge)','Prewitt (edge)','Roberts','LoG','Canny'};
        case 'Corner Detection'
            d.h.ddOp.Items = {'Harris Corners','SIFT Keypoints'};
        case 'Blob Detection'
            d.h.ddOp.Items = {'DoG Blobs','LoG Blobs'};
        case 'HoG'
            d.h.ddOp.Items = {'HoG Visualization','HoG Cell Grid'};
        case 'Hough Transform'
            d.h.ddOp.Items = {'Hough Lines','Hough Circles'};
        case 'RANSAC'
            d.h.ddOp.Items = {'RANSAC Line','RANSAC Circle'};
        case 'Stereo Vision'
            d.h.ddOp.Items = {'Epipolar Lines','Disparity Map','Scanline Matching','Structure from Motion'};
        case 'Object Tracking'
            d.h.ddOp.Items = {'Lucas-Kanade (KLT)'};
    end
    fig.UserData = d;
    configSlider(fig);
    configVisibility(fig);
    applyProc(fig);
end

function cb_OpChanged(fig)
    configSlider(fig);
    configVisibility(fig);
    applyProc(fig);
end

function cb_ParamChanging(fig,e)
    d = fig.UserData;
    updateParamLbl(d.h.lblParam, d.h.ddOp.Value, snap(d.h.ddOp.Value,e.Value));
end

function cb_ParamReleased(fig,e)
    d = fig.UserData;
    v = snap(d.h.ddOp.Value, e.Value);
    d.h.slParam.Value = v;
    fig.UserData = d;
    updateParamLbl(d.h.lblParam, d.h.ddOp.Value, v);
    applyProc(fig);
end

function cb_LPChanging(fig,e)
    d = fig.UserData;
    d.h.lblLP.Text = sprintf('Butterworth LP Order n: %d', round(e.Value));
end

function cb_LPReleased(fig,e)
    d = fig.UserData;
    n = round(e.Value);
    d.h.slLP.Value = n;
    d.h.lblLP.Text = sprintf('Butterworth LP Order n: %d', n);
    fig.UserData = d;
    applyProc(fig);
end

function cb_HPChanging(fig,e)
    d = fig.UserData;
    d.h.lblHP.Text = sprintf('Butterworth HP Order n: %d', round(e.Value));
end

function cb_HPReleased(fig,e)
    d = fig.UserData;
    n = round(e.Value);
    d.h.slHP.Value = n;
    d.h.lblHP.Text = sprintf('Butterworth HP Order n: %d', n);
    fig.UserData = d;
    applyProc(fig);
end

function cb_BoxFiltToggle(fig)
    d = fig.UserData;
    on = d.h.chkBoxFilt.Value;
    d.h.lblBoxSize.Visible = ternary(on,'on','off');
    d.h.slBoxSize.Visible  = ternary(on,'on','off');
    fig.UserData = d;
    relayoutPreproc(fig);
    applyProc(fig);
end

function cb_BoxSizeReleased(fig)
    d = fig.UserData;
    ksz = 2*floor(d.h.slBoxSize.Value/2)+1;
    d.h.slBoxSize.Value = ksz;
    d.h.lblBoxSize.Text = sprintf('Kernel: %dx%d', ksz, ksz);
    fig.UserData = d;
    applyProc(fig);
end

function cb_GaussToggle(fig)
    d = fig.UserData;
    on = d.h.chkGauss.Value;
    d.h.lblGaussSigma.Visible = ternary(on,'on','off');
    d.h.slGaussSigma.Visible  = ternary(on,'on','off');
    fig.UserData = d;
    relayoutPreproc(fig);
    applyProc(fig);
end

function cb_GaussSigmaReleased(fig)
    d = fig.UserData;
    sig = d.h.slGaussSigma.Value;
    d.h.lblGaussSigma.Text = sprintf('Sigma: %.1f', sig);
    fig.UserData = d;
    applyProc(fig);
end

function cb_CloseApp(fig)
    deleteTrackingTimer(fig);
    delete(fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SLIDER HELPERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function configSlider(fig)
    d = fig.UserData; s = d.h.slParam; op = d.h.ddOp.Value;
    switch op
        case {'Box Filter','Weighted Average','Median Filter'}
            s.Limits=[1 15]; s.Value=3; s.MajorTicks=1:2:15; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,3);
        case 'Boosting'        % [F3] A >= 1
            s.Limits=[1 10]; s.Value=1; s.MajorTicks=1:10; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,1);
        case 'Brightness'
            s.Limits=[-1 1]; s.Value=0; s.MajorTicks=-1:0.25:1; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,0);
        case {'Ideal LP','Butterworth LP','Gaussian LP','Ideal HP','Butterworth HP','Gaussian HP'}
            s.Limits=[1 200]; s.Value=50; s.MajorTicks=[1 25 50 75 100 125 150 175 200]; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,50);
        case {'Correlation','Zero-mean Correlation','Sum Square Difference','Normalized Cross Correlation'}
            s.Limits=[0 1]; s.Value=0.8; s.MajorTicks=0:0.1:1; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,0.8);
        case {'Gaussian Reduce','Gaussian Expand','Laplacian Level'}
            s.Limits=[1 5]; s.Value=1; s.MajorTicks=1:5; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,1);
        case {'DoG Bank','Gabor Bank'}
            s.Limits=[1 6]; s.Value=1; s.MajorTicks=1:6; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,1);
        case {'LoG','Canny'}
            s.Limits=[0.5 5]; s.Value=1.5; s.MajorTicks=0.5:0.5:5; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,1.5);
        case 'Harris Corners'
            s.Limits=[0 1]; s.Value=0.01; s.MajorTicks=0:0.1:1; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,0.01);
        case 'SIFT Keypoints'
            s.Limits=[1 200]; s.Value=50; s.MajorTicks=[1 50 100 150 200]; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,50);
        case {'DoG Blobs','LoG Blobs'}
            s.Limits=[0.01 0.30]; s.Value=0.05; s.MajorTicks=[0.01 0.05 0.10 0.20 0.30]; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,0.05);
        case {'HoG Visualization','HoG Cell Grid'}
            s.Limits=[4 32]; s.Value=8; s.MajorTicks=[4 8 16 32]; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,8);
        case 'Hough Lines'
            s.Limits=[1 20]; s.Value=5; s.MajorTicks=1:2:20; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,5);
        case 'Hough Circles'
            s.Limits=[80 100]; s.Value=90; s.MajorTicks=80:5:100; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,90);
        case {'RANSAC Line','RANSAC Circle'}
            s.Limits=[1 20]; s.Value=3; s.MajorTicks=1:2:20; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,3);
        case {'Epipolar Lines','Structure from Motion'}
            s.Limits=[0 1]; s.Value=0; s.MajorTicks=[]; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,0);
        case {'Disparity Map','Scanline Matching'}
            s.Limits=[3 21]; s.Value=9; s.MajorTicks=[3 5 7 9 11 15 21]; s.MinorTicks=[];
            updateParamLbl(d.h.lblParam,op,9);
        otherwise
            s.Limits=[0 1]; s.Value=0; s.MajorTicks=[]; s.MinorTicks=[];
    end
    fig.UserData = d;
end

function configVisibility(fig)
    d=fig.UserData; op=d.h.ddOp.Value; cat=d.h.ddCat.Value;
    noP={'Histogram Equalization','Laplacian 1st','Laplacian 2nd', ...
         'Sobel H','Sobel V','Prewitt','RGB to HSI','RGB to Lab','RGB to YCbCr', ...
         'Sobel (edge)','Prewitt (edge)','Roberts'};
    on_off = @(x) ternary(x,'on','off');
    showParam = ~ismember(op,noP) && ~strcmp(cat,'Color Space');
    d.h.slParam.Visible  = on_off(showParam);
    d.h.lblParam.Visible = on_off(showParam);
    d.h.btnTemplate.Visible = on_off(strcmp(cat,'Template Matching'));
    isTM = strcmp(cat,'Template Matching');
    d.h.axBBox.Visible    = on_off(isTM);
    d.h.lblAxBBox.Visible = on_off(isTM);
    if ~isTM, cla(d.h.axBBox); end
    newCats = {'Pyramids','Template Matching','Filter Banks','Edge Detection','Corner Detection', ...
               'Blob Detection','HoG','Hough Transform','RANSAC','Stereo Vision','Object Tracking'};
    d.h.kp.Visible = on_off(~ismember(cat, newCats));
    d.h.btnLoad.Text = ternary(strcmp(cat,'Object Tracking'),'  Load Video','  Load Image');
    d.h.btnTemplate.Visible = on_off(strcmp(cat,'Template Matching') || strcmp(cat,'Stereo Vision'));
    d.h.btnROI.Visible = on_off(strcmp(cat,'Object Tracking'));
    d.h.btnClearROI.Visible = on_off(strcmp(cat,'Object Tracking'));
    d.h.btnStep.Visible = on_off(strcmp(cat,'Object Tracking'));
    d.h.btnPlay.Visible = on_off(strcmp(cat,'Object Tracking'));
    d.h.btnPause.Visible = on_off(strcmp(cat,'Object Tracking'));
    d.h.btnStop.Visible = on_off(strcmp(cat,'Object Tracking'));
    noParamOps = {'Epipolar Lines','Structure from Motion','Lucas-Kanade (KLT)'};
    showParam = ~ismember(op,noP) && ~strcmp(cat,'Color Space') && ~ismember(op,noParamOps);
    d.h.slParam.Visible  = on_off(showParam);
    d.h.lblParam.Visible = on_off(showParam);
    d.h.slLP.Visible  = on_off(strcmp(op,'Butterworth LP'));
    d.h.lblLP.Visible = on_off(strcmp(op,'Butterworth LP'));
    d.h.slHP.Visible  = on_off(strcmp(op,'Butterworth HP'));
    d.h.lblHP.Visible = on_off(strcmp(op,'Butterworth HP'));
    fig.UserData = d;
    relayoutPreproc(fig);   % collapse / expand BW gap
end

% Reposition all preprocessing controls sequentially so sliders never
% overlap the checkboxes below them. Also collapses the Butterworth gap.
function relayoutPreproc(fig)
    d = fig.UserData;
    sy = d.sy;
    GAP_LBL = round(28 * sy);

    bwOn = strcmp(d.h.slLP.Visible,'on') || strcmp(d.h.slHP.Visible,'on');
    offset = ternary(bwOn, 0, d.h.bwReservedY);

    % Start from header base Y (index 1 in preprocCtrls)
    y = d.h.preprocBaseY(1) + offset;

    function setY(ctrl, yval)
        p = ctrl.Position; p(2) = yval; ctrl.Position = p;
    end

    setY(d.h.lblPreprocHeader, y);  y = y - round(28*sy);
    setY(d.h.chkForceGray,    y);   y = y - round(28*sy);
    setY(d.h.chkHistEq,       y);   y = y - round(32*sy);
    setY(d.h.chkBoxFilt,      y);   y = y - round(28*sy);

    if d.h.chkBoxFilt.Value
        setY(d.h.lblBoxSize, y);  y = y - GAP_LBL;
        setY(d.h.slBoxSize,  y);  y = y - round(60*sy);
    end

    setY(d.h.chkGauss, y);  y = y - round(26*sy);

    if d.h.chkGauss.Value
        setY(d.h.lblGaussSigma, y);  y = y - GAP_LBL;
        setY(d.h.slGaussSigma,  y);  y = y - round(60*sy);
    end

    setY(d.h.chkSobelH, y);  y = y - round(26*sy);
    setY(d.h.chkSobelV, y);
end

function updateParamLbl(lbl,op,val)
    switch op
        case {'Box Filter','Weighted Average','Median Filter'}
            lbl.Text = sprintf('Kernel Size: %d × %d',val,val);
        case 'Boosting'
            lbl.Text = sprintf('Boost A: %.2f  (centre = A+8 = %.2f)',val,val+8);
        case 'Brightness'
            lbl.Text = sprintf('Brightness offset: %+.2f',val);
        case {'Ideal LP','Butterworth LP','Gaussian LP','Ideal HP','Butterworth HP','Gaussian HP'}
            lbl.Text = sprintf('Cutoff D0: %d px',round(val));
        case {'Correlation','Zero-mean Correlation','Sum Square Difference','Normalized Cross Correlation'}
            lbl.Text = sprintf('Threshold: %.2f', val);
        case {'Gaussian Reduce','Gaussian Expand','Laplacian Level'}
            lbl.Text = sprintf('Level: %d',round(val));
        case {'DoG Bank','Gabor Bank'}
            lbl.Text = sprintf('Filter Index: %d',round(val));
        case {'LoG','Canny'}
            lbl.Text = sprintf('Sigma: %.2f',val);
        case {'Sobel (edge)','Prewitt (edge)','Roberts'}
            if val==0, lbl.Text = 'Threshold: auto';
            else,      lbl.Text = sprintf('Threshold: %.2f',val); end
        case 'Harris Corners'
            lbl.Text = sprintf('Min Quality: %.3f',val);
        case 'SIFT Keypoints'
            lbl.Text = sprintf('N Strongest: %d',round(val));
        case {'DoG Blobs','LoG Blobs'}
            lbl.Text = sprintf('Blob Threshold: %.3f', val);
        case {'HoG Visualization','HoG Cell Grid'}
            cs = snapHoGCell(val);
            lbl.Text = sprintf('Cell Size: %d px', cs);
        case 'Hough Lines'
            lbl.Text = sprintf('N Peaks: %d', round(val));
        case 'Hough Circles'
            lbl.Text = sprintf('Sensitivity: %.2f', val/100);
        case {'RANSAC Line','RANSAC Circle'}
            lbl.Text = sprintf('Dist Threshold: %.1f px', val);
        case 'Epipolar Lines'
            lbl.Text = 'Load Right Image via Load Template';
        case 'Structure from Motion'
            lbl.Text = 'SfM: 3D points from 2 views (Load Template)';
        case {'Disparity Map','Scanline Matching'}
            ws = 2*floor(val/2)+1;
            lbl.Text = sprintf('Window Size: %d px', ws);
        otherwise
            lbl.Text = sprintf('Parameter: %.2f',val);
    end
end

function v = snap(op,raw)
    switch op
        case {'Box Filter','Weighted Average','Median Filter'}
            v = max(1,min(15, 2*floor(raw/2)+1));
        case {'Ideal LP','Butterworth LP','Gaussian LP','Ideal HP','Butterworth HP','Gaussian HP'}
            v = max(1,min(200, round(raw)));
        case {'Gaussian Reduce','Gaussian Expand','Laplacian Level'}
            v = max(1,min(5, round(raw)));
        case {'DoG Bank','Gabor Bank'}
            v = max(1,min(6, round(raw)));
        case 'SIFT Keypoints'
            v = max(1,min(200, round(raw)));
        case {'HoG Visualization','HoG Cell Grid'}
            v = snapHoGCell(raw);
        case 'Hough Lines'
            v = max(1,min(20, round(raw)));
        case {'Disparity Map','Scanline Matching'}
            v = max(3,min(21, 2*floor(raw/2)+1));
        case {'RANSAC Line','RANSAC Circle'}
            v = max(1,min(20, round(raw)));
        otherwise
            v = raw;
    end
end

function cs = snapHoGCell(val)
    steps = [4 8 16 32];
    [~,idx] = min(abs(steps - val));
    cs = steps(idx);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROCESSING ORCHESTRATOR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function applyProc(fig)

    d = fig.UserData;
    sx = d.sx;
    sy = d.sy;

    op    = d.h.ddOp.Value;
    cat   = d.h.ddCat.Value;

if strcmp(cat,'Object Tracking')
    d.h.lblAxOrig.Text = 'Tracking Input';
    d.h.lblAxFilt.Text = 'KLT Points';
    d.h.lblAxProc.Text = 'Tracked Object';
else
    if strcmp(d.h.lblAxOrig.Text,'Tracking Input'), d.h.lblAxOrig.Text = 'Original Image'; end
    if strcmp(d.h.lblAxFilt.Text,'KLT Points'), d.h.lblAxFilt.Text = 'Filter / H(u,v)'; end
    if strcmp(d.h.lblAxProc.Text,'Tracked Object'), d.h.lblAxProc.Text = 'Processed Image'; end
end

% Operations that show 3 boxes: Original, Filter/Response, Processed
% NOTE: Prewitt is excluded because it uses 2 kernels (Kh+Kv) and shows
%       only the final magnitude result, so middle box would be redundant
threeAxes = {'Laplacian 1st','Laplacian 2nd','Boosting', ...
             'Sobel H','Sobel V', ...
             'Ideal LP','Butterworth LP','Gaussian LP', ...
             'Ideal HP','Butterworth HP','Gaussian HP', ...
             'Correlation','Zero-mean Correlation','Sum Square Difference','Normalized Cross Correlation', ...
             'Gabor Bank', ...
             'Sobel (edge)','Prewitt (edge)','Roberts', ...
             'Epipolar Lines','Disparity Map','Structure from Motion', ...
             'Lucas-Kanade (KLT)', ...
             };
showFilt = ismember(op,threeAxes);
d.h.axFilt.Visible    = ternary(showFilt,'on','off');
d.h.lblAxFilt.Visible = ternary(showFilt,'on','off');
if ~showFilt, cla(d.h.axFilt); end

% Resize axes depending on whether middle box is shown.
% Use live figure width (was hard-coded 1560 which broke on smaller screens
% where figW = min(1560, sw-40) — axes could overflow the figure).
% axTop_val/axH_val tuned to clear kp top (=328 at sy=1) AND keep labels on-screen.
figW_live = fig.Position(3);
gap = d.spacing.GAP_AXES;
x1_base = round(290*sx);
axTop_val = round(340*sy);
axH_val   = round(590*sy);
axW_small = floor((figW_live - x1_base - 2*gap) / 3);   % 3-box mode: exact fit
axW_large = floor((figW_live - x1_base - 2*gap) / 2);   % 2-box mode: exact fit

if strcmp(cat, 'Template Matching') && showFilt
    % Four boxes: Original | Response Map | Thresholded | Bounding Box
    axW_4p = floor((figW_live - 290*sx - 8 - 3*8) / 4);
    labelY = axTop_val + axH_val + round(4*sy);
    for k = 0:3
        xk = x1_base + k*(axW_4p+gap);
        switch k
            case 0; ax=d.h.axOrig;  lb=d.h.lblAxOrig;
            case 1; ax=d.h.axFilt;  lb=d.h.lblAxFilt;
            case 2; ax=d.h.axProc;  lb=d.h.lblAxProc;
            case 3; ax=d.h.axBBox;  lb=d.h.lblAxBBox;
        end
        ax.Position = [xk, axTop_val, axW_4p, axH_val];
        lb.Position = [xk, labelY, axW_4p, round(22*sy)];
    end
elseif strcmp(cat,'Object Tracking') && showFilt
    % Object Tracking layout:
    %   Left column  (1/3 width): axOrig stacked above axFilt
    %   Right column (2/3 width): axProc, full height (big tracked-output view)
    labelH   = round(22*sy);
    labelGap = round(4*sy);
    leftW    = floor((figW_live - x1_base - gap) / 3);
    rightW   = figW_live - x1_base - gap - leftW;
    halfH    = floor((axH_val - labelH - gap) / 2);

    % axFilt at the bottom of the left column
    d.h.axFilt.Position    = [x1_base, axTop_val, leftW, halfH];
    d.h.lblAxFilt.Position = [x1_base, axTop_val + halfH + labelGap, leftW, labelH];

    % axOrig stacked above axFilt
    axOrig_y = axTop_val + halfH + labelH + gap;
    d.h.axOrig.Position    = [x1_base, axOrig_y, leftW, halfH];
    d.h.lblAxOrig.Position = [x1_base, axOrig_y + halfH + labelGap, leftW, labelH];

    % axProc on the right, full height
    right_x = x1_base + leftW + gap;
    d.h.axProc.Position    = [right_x, axTop_val, rightW, axH_val];
    d.h.lblAxProc.Position = [right_x, axTop_val + axH_val + labelGap, rightW, labelH];
elseif showFilt
    % Three boxes — original layout
    d.h.axOrig.Position = [x1_base, axTop_val, axW_small, axH_val];
    d.h.axFilt.Position = [x1_base+axW_small+gap, axTop_val, axW_small, axH_val];
    d.h.axProc.Position = [x1_base+2*(axW_small+gap), axTop_val, axW_small, axH_val];
    % Update label positions: x, y (just above axes), width
    labelY = axTop_val + axH_val + round(4*sy);
    d.h.lblAxOrig.Position = [x1_base, labelY, axW_small, round(22*sy)];
    d.h.lblAxFilt.Position = [x1_base+axW_small+gap, labelY, axW_small, round(22*sy)];
    d.h.lblAxProc.Position = [x1_base+2*(axW_small+gap), labelY, axW_small, round(22*sy)];
else
    if strcmp(op, 'Gaussian Expand')
        % Both axes equal size — canvas approach keeps relative sizes correct
        axW_eq  = round(600*sx);
        axH_eq  = round(820*sy);
        axBot   = round(50*sy);
        axX_r   = x1_base + axW_eq + gap*4;
        d.h.axOrig.Position = [x1_base, axBot, axW_eq, axH_eq];
        d.h.axProc.Position = [axX_r,   axBot, axW_eq, axH_eq];
        labelY_eq = axBot + axH_eq + round(4*sy);
        d.h.lblAxOrig.Position = [x1_base, labelY_eq, axW_eq, round(22*sy)];
        d.h.lblAxProc.Position = [axX_r,   labelY_eq, axW_eq, round(22*sy)];
    else
        % Normal two-box layout
        d.h.axOrig.Position = [x1_base,             axTop_val, axW_large, axH_val];
        d.h.axProc.Position = [x1_base+axW_large+gap, axTop_val, axW_large, axH_val];
        labelY = axTop_val + axH_val + round(4*sy);
        d.h.lblAxOrig.Position = [x1_base,              labelY, axW_large, round(22*sy)];
        d.h.lblAxProc.Position = [x1_base+axW_large+gap, labelY, axW_large, round(22*sy)];
    end
end
fig.UserData = d;

    if strcmp(cat,'Object Tracking')
        % TODO: route loaded video frames through ROI init and playback/timer logic here.
        return;
    end

    % Layout is now done — bail out of image-processing if nothing loaded yet.
    % (Moved here from the top so the axes get properly sized on first paint,
    % otherwise the initial design positions overflowed the figure width.)
    if isempty(d.origImg), return; end

    param = snap(op, d.h.slParam.Value);
    nLP   = round(d.h.slLP.Value);
    nHP   = round(d.h.slHP.Value);

    % Apply pre-processing to input before any operation
    inputImg = preProcess(d.origImg, d.h);
    imshow(inputImg, 'Parent', d.h.axOrig);

    filtImg = [];

    switch cat
        case 'Enhancement'
            d.procImg = doEnhancement(inputImg, op, param);

        case 'Spatial Filtering'
            [d.procImg, filtImg] = doSpatial(inputImg, op, param);
            if ~isempty(filtImg)
                imshow(filtImg,'Parent',d.h.axFilt);
                if ismember(op, {'Sobel H', 'Sobel V'})
                    d.h.lblAxFilt.Text = 'Gradient (Normalized)';
                else
                    d.h.lblAxFilt.Text = 'Filter Response';
                end
            end

        case 'Frequency Filtering'
            [d.procImg, filtImg] = doFrequency(inputImg, op, param, nLP, nHP);
            if ~isempty(filtImg)
                imshow(filtImg,'Parent',d.h.axFilt);
                d.h.lblAxFilt.Text = 'H(u,v) Frequency Mask';
            end

        case 'Color Space'
            d.procImg = doColorSpace(fig, inputImg, op);

        case 'Pyramids'
            [d.procImg, ~] = doPyramids(inputImg, op, param);
            if strcmp(op,'Gaussian Expand') && ~isempty(d.procImg)
                gOrig = gray_safe(inputImg);
                [eH,eW] = size(d.procImg);
                [oH,oW] = size(gOrig);
                origCanvas = zeros(eH, eW, 'uint8');
                r0 = floor((eH-oH)/2)+1; c0 = floor((eW-oW)/2)+1;
                origCanvas(r0:r0+oH-1, c0:c0+oW-1) = gOrig;
                imshow(origCanvas,'Parent',d.h.axOrig);
            end

        case 'Template Matching'
            delete(findobj(fig,'Tag','tmpHint'));   % always clean before redraw
            if isempty(d.templateImg)
                cla(d.h.axProc); cla(d.h.axFilt);
                d.h.lblAxFilt.Text = 'Correlation Map';
                uilabel(d.h.axProc.Parent,'Text','Load a template first.', ...
                    'Position',[d.h.axProc.Position(1) d.h.axProc.Position(2)+200 ...
                                d.h.axProc.Position(3) 30], ...
                    'FontColor',[1 0.6 0.2],'FontSize',13,'Tag','tmpHint');
            else
                [d.procImg, filtImg, bboxImg] = doTemplateMatch(inputImg, d.templateImg, op, param);
                if ~isempty(filtImg)
                    imshow(filtImg,'Parent',d.h.axFilt);
                    d.h.lblAxFilt.Text = 'Response Map';
                end
                if ~isempty(bboxImg)
                    imshow(bboxImg,'Parent',d.h.axBBox);
                    d.h.lblAxBBox.Text = 'Match Location';
                end
            end

        case 'Filter Banks'
            [d.procImg, filtImg] = doFilterBank(inputImg, op, param);
            if ~isempty(filtImg)
                imshow(filtImg,'Parent',d.h.axFilt);
                d.h.lblAxFilt.Text = sprintf('Filter #%d',round(param));
            end

        case 'Edge Detection'
            [d.procImg, filtImg] = doEdgeDetect(inputImg, op, param);
            if ~isempty(filtImg)
                imshow(filtImg,'Parent',d.h.axFilt);
                d.h.lblAxFilt.Text = 'Gradient Magnitude';
            else
                cla(d.h.axFilt);   % LoG / Canny: no meaningful middle box
            end

        case 'Corner Detection'
            [grayImg, ~, pts] = doCornerDetect(inputImg, op, param);
            % Draw markers directly into image pixels (reliable in uiaxes)
            marked = grayImg;
            if ~isempty(pts) && isobject(pts) && pts.Count > 0
                if strcmp(op,'SIFT Keypoints')
                    nShow = min(round(param), pts.Count);
                    strongest = pts.selectStrongest(nShow);
                    xy = round(strongest.Location);
                    marked = insertMarker(grayImg, xy, 'circle', ...
                        'Color', [0 230 0], 'Size', 6);
                else
                    nShow = min(200, pts.Count);
                    strongest = pts.selectStrongest(nShow);
                    xy = round(strongest.Location);
                    marked = insertMarker(grayImg, xy, '+', ...
                        'Color', [0 230 0], 'Size', 10);
                end
            end
            cla(d.h.axProc);
            d.procImg = marked;

        case 'Blob Detection'
            [d.procImg, ~] = doBlobDetect(inputImg, op, param);

        case 'HoG'
            [d.procImg, ~] = doHoG(inputImg, op, param);

        case 'Hough Transform'
            [d.procImg, ~] = doHough(inputImg, op, param);

        case 'RANSAC'
            [d.procImg, ~] = doRANSAC(inputImg, op, param);

        case 'Stereo Vision'
            delete(findobj(fig,'Tag','stereoHint'));
            if isempty(d.templateImg)
                cla(d.h.axProc); cla(d.h.axFilt);
                d.h.lblAxFilt.Text = 'Right Image';
                uilabel(d.h.axProc.Parent,'Text','Load right image via Load Template.', ...
                    'Position',[d.h.axProc.Position(1) d.h.axProc.Position(2)+200 ...
                                d.h.axProc.Position(3) 30], ...
                    'FontColor',[1 0.6 0.2],'FontSize',13,'Tag','stereoHint');
            else
                [d.procImg, filtImg, leftOverride] = doStereo(inputImg, d.templateImg, op, param);
                if ~isempty(filtImg)
                    imshow(filtImg,'Parent',d.h.axFilt);
                    switch op
                        case 'Scanline Matching'
                            d.h.lblAxFilt.Text = 'Right + Candidate Windows';
                        otherwise
                            d.h.lblAxFilt.Text = 'Right Image';
                    end
                end
                if ~isempty(leftOverride)
                    imshow(leftOverride,'Parent',d.h.axOrig);
                end
            end
    end

    if ~isempty(d.procImg)
        imshow(d.procImg,'Parent',d.h.axProc);
        if ismember(op, {'Sobel H', 'Sobel V'})
            d.h.axProc.Title.String = [op ' — Edge Magnitude'];
        elseif ismember(op, {'Correlation','Zero-mean Correlation','Sum Square Difference','Normalized Cross Correlation'})
            d.h.axProc.Title.String = 'Thresholded Image';
        else
            d.h.axProc.Title.String = op;
        end
    end

    fig.UserData = d;
    updateKernelPanel(fig, op, param, nLP, nHP);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  IMAGE PROCESSING FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function img = preProcess(img, h)
    % Force-grayscale runs first so downstream ops see single-channel input.
    if isfield(h,'chkForceGray') && h.chkForceGray.Value && size(img,3) == 3
        img = rgb2gray(img);
    end
    if h.chkHistEq.Value
        if size(img,3) == 3
            for c = 1:3, img(:,:,c) = histeq(img(:,:,c)); end
        else
            img = histeq(img);
        end
    end
    if h.chkBoxFilt.Value
        ksz = 2*floor(h.slBoxSize.Value/2)+1;
        K = ones(ksz,ksz,'double') / (ksz*ksz);
        if size(img,3) == 3
            d = im2double(img);
            for c = 1:3, d(:,:,c) = imfilter(d(:,:,c), K, 'replicate'); end
            img = im2uint8(d);
        else
            img = im2uint8(imfilter(im2double(img), K, 'replicate'));
        end
    end
    if h.chkGauss.Value
        sig = h.slGaussSigma.Value;
        if size(img,3) == 3
            d = im2double(img);
            for c = 1:3, d(:,:,c) = imgaussfilt(d(:,:,c), sig); end
            img = im2uint8(d);
        else
            img = im2uint8(imgaussfilt(im2double(img), sig));
        end
    end
    % Sobel H and Sobel V as real preprocessing — modify pixel data so
    % downstream ops see the gradient image instead of the original.
    sH = isfield(h,'chkSobelH') && h.chkSobelH.Value;
    sV = isfield(h,'chkSobelV') && h.chkSobelV.Value;
    if sH || sV
        Kh = [-1 -2 -1; 0 0 0; 1 2 1];   % horizontal-edge kernel (Gy)
        Kv = [-1 0 1; -2 0 2; -1 0 1];   % vertical-edge kernel (Gx)
        applySobel = @(ch) localSobelMix(ch, Kh, Kv, sH, sV);
        if size(img,3) == 3
            d = im2double(img);
            for c = 1:3, d(:,:,c) = applySobel(d(:,:,c)); end
            img = im2uint8(min(max(d,0),1));
        else
            img = im2uint8(min(max(applySobel(im2double(img)),0),1));
        end
    end
end

function out = localSobelMix(ch, Kh, Kv, useH, useV)
    if useH && useV
        gx = imfilter(ch, Kv, 'replicate');
        gy = imfilter(ch, Kh, 'replicate');
        out = sqrt(gx.^2 + gy.^2);
    elseif useH
        out = abs(imfilter(ch, Kh, 'replicate'));
    else
        out = abs(imfilter(ch, Kv, 'replicate'));
    end
    out = mat2gray(out);
end

% Display-only overlay: paints Sobel edges on top of an image for the
% Original-axes preview without modifying the data pipeline.
function imgDisp = applySobelOverlay(img, h)
    imgDisp = img;
    if ~h.chkSobel.Value, return; end
    gpp = im2double(gray_safe(img));
    Gx  = imfilter(gpp, fspecial('sobel')', 'replicate');
    Gy  = imfilter(gpp, fspecial('sobel'),  'replicate');
    mag = mat2gray(sqrt(Gx.^2 + Gy.^2));
    if size(img,3) == 3
        ov = im2double(img);
        ov(:,:,1) = min(1, ov(:,:,1) + mag);
        ov(:,:,2) = max(0, ov(:,:,2) - mag);
        ov(:,:,3) = max(0, ov(:,:,3) - mag);
        imgDisp = im2uint8(ov);
    else
        ov = repmat(im2double(img), 1, 1, 3);
        ov(:,:,1) = min(1, ov(:,:,1) + mag);
        imgDisp = im2uint8(ov);
    end
end

function out = doEnhancement(img, op, param)
    dbl = im2double(img);
    switch op
        case 'Brightness'
            out = im2uint8(min(max(dbl+param,0),1));
        case 'Histogram Equalization'
            if size(dbl,3)==3
                hsv=rgb2hsv(dbl); hsv(:,:,3)=histeq(hsv(:,:,3));
                out=im2uint8(hsv2rgb(hsv));
            else
                out=histeq(im2uint8(dbl));
            end
        otherwise, out=img;
    end
end

function [out,filtImg] = doSpatial(img, op, param)
    filtImg=[]; ksize=max(1,2*floor(param/2)+1);
    switch op
        case 'Box Filter'
            out=imfilter(img,ones(ksize)/ksize^2,'replicate');

        case 'Weighted Average'
            if ksize==3
                Kw=(1/16)*[1 2 1;2 4 2;1 2 1];
            else
                sig=max(ksize/4,0.5);
                [gx,gy]=meshgrid(-(ksize-1)/2:(ksize-1)/2);
                Kw=exp(-(gx.^2+gy.^2)/(2*sig^2)); Kw=Kw/sum(Kw(:));
            end
            if size(img,3)==3
                out=zeros(size(img),'uint8');
                for c=1:3, out(:,:,c)=im2uint8(imfilter(im2double(img(:,:,c)),Kw,'replicate')); end
            else
                out=im2uint8(imfilter(im2double(img),Kw,'replicate'));
            end

        case 'Median Filter'
            if size(img,3)==3
                out=zeros(size(img),'uint8');
                for c=1:3, out(:,:,c)=medfilt2(img(:,:,c),[ksize ksize]); end
            else
                out=medfilt2(img,[ksize ksize]);
            end

        case 'Laplacian 1st'   % DIP Ch3 p.42 – positive centre → add
            K=[0 -1 0;-1 4 -1;0 -1 0];
            filtImg=kernelResp(img,K);
            out=im2uint8(min(max(im2double(img)+imfilter(im2double(img),K,'replicate'),0),1));

        case 'Laplacian 2nd'   % DIP Ch3 p.42 – 8-connectivity
            K=[-1 -1 -1;-1 8 -1;-1 -1 -1];
            filtImg=kernelResp(img,K);
            out=im2uint8(min(max(im2double(img)+imfilter(im2double(img),K,'replicate'),0),1));

        case 'Boosting'        % DIP Ch3 p.46 – [F3] A>=1
            A=param;
            Kl=[-1 -1 -1;-1 8 -1;-1 -1 -1];
            filtImg=im2uint8(min(max(imfilter(im2double(img),Kl,'replicate'),0),1));
            Kb=[-1 -1 -1;-1 (A+8) -1;-1 -1 -1];
            out=im2uint8(min(max(imfilter(im2double(img),Kb,'replicate'),0),1));

        case 'Sobel H'         % DIP Ch3 p.47 – Gy
            K=[-1 -2 -1;0 0 0;1 2 1];
            gray=im2double(gray_safe(img));
            % Middle box: Normalized gradient response (shows gradient pattern)
            rawGrad=imfilter(gray,K,'replicate');
            filtImg=im2uint8(mat2gray(rawGrad));
            % Right box: Absolute gradient magnitude (edge strength)
            out=im2uint8(min(abs(rawGrad),1));

        case 'Sobel V'         % DIP Ch3 p.47 – Gx
            K=[-1 0 1;-2 0 2;-1 0 1];
            gray=im2double(gray_safe(img));
            % Middle box: Normalized gradient response (shows gradient pattern)
            rawGrad=imfilter(gray,K,'replicate');
            filtImg=im2uint8(mat2gray(rawGrad));
            % Right box: Absolute gradient magnitude (edge strength)
            out=im2uint8(min(abs(rawGrad),1));

        case 'Prewitt'         % DIP Ch3 p.47 - uses 2 kernels
            Kh=[-1 -1 -1;0 0 0;1 1 1]; Kv=[-1 0 1;-1 0 1;-1 0 1];
            gray=im2double(gray_safe(img));
            mag=sqrt(imfilter(gray,Kh,'replicate').^2+imfilter(gray,Kv,'replicate').^2);
            % No filtImg for Prewitt (uses 2 kernels, middle box not shown)
            out=im2uint8(min(mag,1));  % Final edge magnitude result

        otherwise, out=img;
    end
end

function [out,maskImg] = doFrequency(img, op, param, nLP, nHP)
    dbl=im2double(img); D0=max(param,1);
    if size(dbl,3)==3, [M,N,~]=size(dbl); else, [M,N]=size(dbl); end
    H=buildFreqMask(M,N,op,D0,nLP,nHP);  % [F1] correct centred D
    maskImg=im2uint8(mat2gray(H));
    if size(dbl,3)==3
        out=zeros(size(dbl));
        for c=1:3, out(:,:,c)=freqCh(dbl(:,:,c),H); end
        out=im2uint8(min(max(out,0),1));
    else
        out=im2uint8(min(max(freqCh(dbl,H),0),1));
    end
end

% [F1] FIX: correct centred D(u,v) per DIP Ch4 p.24
%      D(u,v) = sqrt[(u - N/2)^2 + (v - M/2)^2]
function H = buildFreqMask(M, N, op, D0, nLP, nHP)
    [u,v]=meshgrid(1:N,1:M);
    % MATLAB fftshift convention: DC at (floor(M/2)+1, floor(N/2)+1)
    D=sqrt((u-(floor(N/2)+1)).^2+(v-(floor(M/2)+1)).^2);
    switch op
        case 'Ideal LP',       H=double(D<=D0);
        case 'Ideal HP',       H=double(D>D0);
        case 'Butterworth LP', H=1./(1+(D./D0).^(2*nLP));
        case 'Butterworth HP', H=1./(1+(D0./max(D,1e-6)).^(2*nHP));
        case 'Gaussian LP',    H=exp(-(D.^2)./(2*D0^2));
        case 'Gaussian HP',    H=1-exp(-(D.^2)./(2*D0^2));
        otherwise,             H=ones(M,N);
    end
end

function r = freqCh(ch,H)
    [M,N]=size(ch);
    r=real(ifft2(ifftshift(H.*fftshift(fft2(ch,M,N)))));
end

function out = doColorSpace(fig,img,op)
    dbl=im2double(img);
    if size(dbl,3)~=3
        uialert(fig,'RGB image required.','Error'); out=img; return;
    end
    switch op
        case 'RGB to HSI'
            R=dbl(:,:,1);G=dbl(:,:,2);B=dbl(:,:,3);
            num=0.5*((R-G)+(R-B));
            den=sqrt((R-G).^2+(R-B).*(G-B))+1e-10;
            theta=acos(min(max(num./den,-1),1));
            H_ch=theta; H_ch(B>G)=2*pi-H_ch(B>G); H_ch=H_ch/(2*pi);
            S_ch=1-3.*min(cat(3,R,G,B),[],3)./(R+G+B+1e-10);
            I_ch=(R+G+B)/3;
            out=im2uint8(min(max(cat(3,H_ch,S_ch,I_ch),0),1));
        case 'RGB to Lab'
            lab=rgb2lab(dbl);
            lab(:,:,1)=lab(:,:,1)/100;
            lab(:,:,2)=(lab(:,:,2)+128)/255;
            lab(:,:,3)=(lab(:,:,3)+128)/255;
            out=im2uint8(min(max(lab,0),1));
        case 'RGB to YCbCr'
            out=rgb2ycbcr(im2uint8(dbl));
        otherwise, out=img;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  NEW CV PROCESSING FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out, midImg] = doPyramids(img, op, level)
    level = max(1, round(level));
    gray = gray_safe(img);
    midImg = [];
    switch op
        case 'Gaussian Reduce'
            reduced = gray;
            for k = 1:level, reduced = impyramid(reduced,'reduce'); end
            [origH, origW] = size(gray);
            [rH, rW] = size(reduced);
            canvas = zeros(origH, origW, 'uint8');
            r0 = floor((origH - rH)/2) + 1;
            c0 = floor((origW - rW)/2) + 1;
            canvas(r0:r0+rH-1, c0:c0+rW-1) = reduced;
            out = canvas;
        case 'Gaussian Expand'
            expanded = gray;
            for k = 1:level, expanded = impyramid(expanded,'expand'); end
            out = expanded;
        case 'Laplacian Level'
            reduced = gray;
            for k = 1:level, reduced = impyramid(reduced,'reduce'); end
            recon = reduced;
            for k = 1:level, recon = impyramid(recon,'expand'); end
            recon = imresize(recon, [size(gray,1) size(gray,2)]);
            lap = im2double(gray) - im2double(recon);
            out = im2uint8(mat2gray(lap));
    end
end

function [out, midImg, bboxImg] = doTemplateMatch(origImg, templateImg, op, thresh)
    out = []; midImg = []; bboxImg = [];
    gray = im2double(gray_safe(origImg));
    tmpl = im2double(gray_safe(templateImg));
    [th, tw] = size(tmpl);
    [ih, iw] = size(gray);
    if th >= ih || tw >= iw, out = origImg; return; end

    switch op
        case 'Correlation'
            resp = imfilter(gray, rot90(tmpl,2), 'replicate');
            resp_disp = mat2gray(resp);
            locs = tmPeaks(resp_disp, thresh, th, tw);
            boxes = locsToBBoxes(locs, tw, th, 'center', ih, iw);

        case 'Zero-mean Correlation'
            tmpl_zm = tmpl - mean(tmpl(:));
            resp = imfilter(gray, rot90(tmpl_zm,2), 'replicate');
            resp_disp = mat2gray(resp);
            locs = tmPeaks(resp_disp, thresh, th, tw);
            boxes = locsToBBoxes(locs, tw, th, 'center', ih, iw);

        case 'Sum Square Difference'
            t_sq = sum(tmpl(:).^2);
            corr_v   = conv2(gray, rot90(tmpl,2), 'valid');
            local_sq = conv2(gray.^2, ones(th,tw), 'valid');
            ssd  = t_sq - 2*corr_v + local_sq;
            % Fill padding with worst-case SSD (max), not 0, so 1-mat2gray puts
            % padding into dark/bad-match band instead of false bright peaks.
            full = max(ssd(:)) * ones(ih, iw);
            full(1:size(ssd,1), 1:size(ssd,2)) = ssd;
            resp_disp = 1 - mat2gray(full);
            locs = tmPeaks(resp_disp, thresh, th, tw);
            boxes = locsToBBoxes(locs, tw, th, 'topleft', ih, iw);

        case 'Normalized Cross Correlation'
            C = normxcorr2(tmpl, gray);
            midImg  = im2uint8(mat2gray(C));
            out     = im2uint8(C >= thresh);
            locs    = tmPeaks(C, thresh, th, tw);
            boxes   = locsToBBoxes(locs, tw, th, 'ncc', ih, iw);
            bboxImg = drawAllBBoxes(origImg, boxes);
            return;
    end

    midImg  = im2uint8(resp_disp);
    out     = im2uint8(resp_disp >= thresh);
    bboxImg = drawAllBBoxes(origImg, boxes);
end

% Find all local maxima in resp that are >= thresh,
% separated by at least (minH x minW) to avoid duplicate detections.
function locs = tmPeaks(resp, thresh, minH, minW)
    locs = [];
    above = resp >= thresh;
    if ~any(above(:)), return; end
    se      = strel('rectangle', [max(3, minH), max(3, minW)]);
    dilated = imdilate(resp, se);
    isMax   = above & (resp >= dilated - 1e-10);
    [r, c]  = find(isMax);
    locs    = [r, c];
end

% Convert peak pixel locations to [x y w h] bounding boxes.
function boxes = locsToBBoxes(locs, tw, th, conv, ih, iw)
    boxes = zeros(0, 4);
    if isempty(locs), return; end
    for i = 1:size(locs,1)
        pr = locs(i,1); pc = locs(i,2);
        switch conv
            case 'center'
                bx = pc - floor(tw/2); by = pr - floor(th/2);
            case 'topleft'
                bx = pc; by = pr;
            case 'ncc'
                bx = pc - tw + 1; by = pr - th + 1;
        end
        bx = max(1, bx); by = max(1, by);
        bx = min(bx, iw - tw + 1); by = min(by, ih - th + 1);
        boxes(end+1, :) = [bx, by, tw, th]; %#ok<AGROW>
    end
end

function img_out = drawAllBBoxes(origImg, boxes)
    if size(origImg,3) == 1
        rgb = repmat(origImg, 1, 1, 3);
    else
        rgb = origImg;
    end
    if isempty(boxes)
        img_out = rgb; return;
    end
    img_out = insertShape(rgb, 'Rectangle', boxes, ...
        'Color', [255 0 0], 'LineWidth', 3);
end

function [out, midImg] = doFilterBank(img, op, idx)
    idx = max(1, min(6, round(idx)));
    gray = im2double(gray_safe(img));
    switch op
        case 'DoG Bank'
            pairs = [1 2; 2 3; 3 5; 1 3; 2 5; 1 5];
            s1 = pairs(idx,1); s2 = pairs(idx,2);
            g1 = imgaussfilt(gray, s1);
            g2 = imgaussfilt(gray, s2);
            dog = g1 - g2;
            midImg = [];
            out = im2uint8(mat2gray(dog));
        case 'Gabor Bank'
            thetas = (0:5)*30;
            wavelength = 8;
            gb = gabor(wavelength, thetas(idx));
            resp = imgaborfilt(gray, gb);
            ksz = 21;
            [gx, gy] = meshgrid(-(ksz-1)/2:(ksz-1)/2);
            sigma_g = wavelength / pi * sqrt(log(2)/2) * (2+1)/(2-1);
            kreal = exp(-0.5*(gx.^2+gy.^2)/sigma_g^2) .* ...
                    cos(2*pi/wavelength*(gx*cosd(thetas(idx))+gy*sind(thetas(idx))));
            midImg = im2uint8(mat2gray(kreal));
            out = im2uint8(mat2gray(abs(resp)));
    end
end

function [out, midImg] = doEdgeDetect(img, op, param)
    gray = gray_safe(img);
    midImg = [];
    bw = false(size(gray));
    gd = im2double(gray);
    switch op
        case 'Sobel (edge)'
            [~, ~, Gx, Gy] = edge(gray, 'Sobel');
            midImg = im2uint8(mat2gray(sqrt(double(Gx).^2 + double(Gy).^2)));
            if param > 0, bw = edge(gray,'Sobel',param); else, bw = edge(gray,'Sobel'); end
        case 'Prewitt (edge)'
            [~, ~, Gx, Gy] = edge(gray, 'Prewitt');
            midImg = im2uint8(mat2gray(sqrt(double(Gx).^2 + double(Gy).^2)));
            if param > 0, bw = edge(gray,'Prewitt',param); else, bw = edge(gray,'Prewitt'); end
        case 'Roberts'
            Kx = [1 0; 0 -1]; Ky = [0 1; -1 0];
            mag = sqrt(imfilter(gd,Kx,'replicate').^2 + imfilter(gd,Ky,'replicate').^2);
            midImg = im2uint8(mat2gray(mag));
            if param > 0, bw = edge(gray,'Roberts',param); else, bw = edge(gray,'Roberts'); end
        case 'LoG'
            bw = edge(gray, 'log', [], param);
        case 'Canny'
            bw = edge(gray, 'Canny', [], param);
    end
    out = im2uint8(bw);
end

function [grayOut, midImg, pts] = doCornerDetect(img, op, param)
    pts = [];
    midImg = [];
    gray = gray_safe(img);
    grayOut = repmat(gray, 1, 1, 3);
    switch op
        case 'Harris Corners'
            pts = detectHarrisFeatures(gray, 'MinQuality', max(0, param));
            [Ix, Iy] = imgradientxy(im2double(gray));
            Ix2 = imgaussfilt(Ix.^2, 1);
            Iy2 = imgaussfilt(Iy.^2, 1);
            Ixy = imgaussfilt(Ix.*Iy, 1);
            k = 0.04;
            R = (Ix2.*Iy2 - Ixy.^2) - k*(Ix2+Iy2).^2;
            midImg = im2uint8(mat2gray(R));
        case 'SIFT Keypoints'
            pts = detectSIFTFeatures(gray);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  TASK 3 PROCESSING FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out, midImg] = doBlobDetect(img, op, thresh)
    gray = im2double(gray_safe(img));
    sigmas = [1 2 4 8];
    out = []; midImg = [];
    rgb = repmat(im2uint8(gray), 1, 1, 3);

    switch op
        case 'DoG Blobs'
            % Build DoG scale-space
            dogs = cell(1, numel(sigmas)-1);
            for k = 1:numel(sigmas)-1
                g1 = imgaussfilt(gray, sigmas(k));
                g2 = imgaussfilt(gray, sigmas(k+1));
                dogs{k} = g1 - g2;
            end
            midImg = im2uint8(mat2gray(dogs{1}));
            circles = zeros(0,3);
            for k = 1:numel(dogs)
                d = dogs{k};
                absD = abs(d);
                dil = imdilate(absD, strel('disk', 3));
                peaks = absD >= dil - 1e-10 & absD >= thresh;
                [ry, cx] = find(peaks);
                r = sigmas(k+1) * sqrt(2);
                for i = 1:numel(ry)
                    circles(end+1,:) = [cx(i), ry(i), r]; %#ok<AGROW>
                end
            end
            if ~isempty(circles)
                out = insertShape(rgb, 'circle', circles, 'Color','cyan','LineWidth',2);
            else
                out = rgb;
            end

        case 'LoG Blobs'
            % Scale-normalised LoG blob detection
            allResp = zeros([size(gray), numel(sigmas)]);
            for k = 1:numel(sigmas)
                sig = sigmas(k);
                ksz = 2*ceil(3*sig)+1;
                [gx,gy] = meshgrid(-(ksz-1)/2:(ksz-1)/2);
                r2 = gx.^2+gy.^2;
                logK = -(1/(pi*sig^4))*(1-r2/(2*sig^2)).*exp(-r2/(2*sig^2));
                logK = logK * sig^2;
                resp = imfilter(gray, logK, 'replicate');
                allResp(:,:,k) = abs(resp);
            end
            midImg = im2uint8(mat2gray(allResp(:,:,2)));
            circles = zeros(0,3);
            for k = 1:numel(sigmas)
                d = allResp(:,:,k);
                dil = imdilate(d, strel('disk', 4));
                peaks = d >= dil - 1e-10 & d >= thresh;
                [ry, cx] = find(peaks);
                r = sigmas(k) * sqrt(2);
                for i = 1:numel(ry)
                    circles(end+1,:) = [cx(i), ry(i), r]; %#ok<AGROW>
                end
            end
            if ~isempty(circles)
                out = insertShape(rgb, 'circle', circles, 'Color','yellow','LineWidth',2);
            else
                out = rgb;
            end
    end
end

function [out, midImg] = doHoG(img, op, param)
    cellSz = snapHoGCell(param);
    gray = gray_safe(img);
    midImg = [];
    [~, hogVis] = extractHOGFeatures(gray, 'CellSize', [cellSz cellSz]);

    % Render HoG visualization to an offscreen figure, capture as image
    [H, W] = size(gray);
    tmpFig = figure('Visible','off','Color','k', ...
        'Position',[100 100 W H], 'MenuBar','none','ToolBar','none');
    tmpAx = axes('Parent',tmpFig,'Position',[0 0 1 1]);
    switch op
        case 'HoG Visualization'
            imshow(gray, 'Parent', tmpAx);
            hold(tmpAx,'on');
            plot(hogVis, tmpAx, 'Color','green');
            hold(tmpAx,'off');
        case 'HoG Cell Grid'
            % Glyphs only over black background
            imshow(zeros(H,W,'uint8'),'Parent',tmpAx);
            hold(tmpAx,'on');
            plot(hogVis, tmpAx, 'Color','green');
            hold(tmpAx,'off');
    end
    axis(tmpAx,'off');
    drawnow;
    frame = getframe(tmpAx);
    close(tmpFig);
    out = frame.cdata;
    % Resize to match original image size to keep layout consistent
    out = imresize(out, [H W]);
end

function [out, midImg] = doHough(img, op, param)
    gray = gray_safe(img);
    BW = edge(gray, 'canny');
    midImg = [];
    origRGB = ternary(size(img,3)==3, img, repmat(img,1,1,3));

    switch op
        case 'Hough Lines'
            [H, theta, rho] = hough(BW, 'RhoResolution', 0.5, 'Theta', -90:0.5:89);
            midImg = im2uint8(imadjust(rescale(H)));
            nPeaks = max(1, round(param));
            P = houghpeaks(H, nPeaks, 'Threshold', ceil(0.3*max(H(:))));
            lines = houghlines(BW, theta, rho, P, 'MinLength', 15);
            out = origRGB;
            for k = 1:length(lines)
                xy = [lines(k).point1; lines(k).point2];
                out = insertShape(out, 'line', [xy(1,:) xy(2,:)], ...
                    'Color','green','LineWidth',2);
            end

        case 'Hough Circles'
            sensitivity = param / 100;
            minR = 5;
            maxR = max(6, round(min(size(gray))/2));
            midImg = im2uint8(BW);
            try
                [centers, radii] = imfindcircles(gray, [minR maxR], ...
                    'Sensitivity', sensitivity, 'EdgeThreshold', 0.1);
                out = origRGB;
                if ~isempty(centers)
                    circData = [centers(:,1), centers(:,2), radii];
                    out = insertShape(out, 'circle', circData, ...
                        'Color','red','LineWidth',2);
                end
            catch
                out = origRGB;
            end
    end
end

function [out, midImg] = doRANSAC(img, op, distThresh)
    gray = gray_safe(img);
    BW = edge(gray, 'canny');
    midImg = im2uint8(BW);
    baseRGB = ternary(size(img,3)==3, img, repmat(img,1,1,3));
    out = baseRGB;
    [yp, xp] = find(BW);
    pts = double([xp yp]);
    if size(pts,1) < 4, return; end
    nIter = 500;

    switch op
        case 'RANSAC Line'
            bestInliers = [];
            for iter = 1:nIter
                idx = randperm(size(pts,1), 2);
                p1 = pts(idx(1),:); p2 = pts(idx(2),:);
                dx = p2(1)-p1(1); dy = p2(2)-p1(2);
                len = sqrt(dx^2+dy^2);
                if len < 1e-6, continue; end
                a = -dy/len; b = dx/len; c = -(a*p1(1)+b*p1(2));
                dists = abs(a*pts(:,1) + b*pts(:,2) + c);
                inliers = find(dists < distThresh);
                if numel(inliers) > numel(bestInliers)
                    bestInliers = inliers;
                end
            end
            if ~isempty(bestInliers)
                inPts = pts(bestInliers,:);
                out = baseRGB;
                [~,~,V] = svd([inPts(:,1)-mean(inPts(:,1)), inPts(:,2)-mean(inPts(:,2))], 0);
                dir = V(:,1)';
                ctr = mean(inPts);
                t = [-600 600];
                lx = ctr(1) + t*dir(1); ly = ctr(2) + t*dir(2);
                [H2,W2] = size(gray);
                lx = max(1,min(W2,lx)); ly = max(1,min(H2,ly));
                out = insertShape(out, 'line', [lx(1) ly(1) lx(2) ly(2)], ...
                    'Color','red','LineWidth',2);
            end

        case 'RANSAC Circle'
            bestInliers = [];
            bestCircle = [];
            % Radius constraints prevent the "huge circle grazing many objects"
            % failure mode. Forces detector to find object-sized circles.
            [Hg, Wg] = size(gray);
            minR = 10;
            maxR = min(Hg, Wg) / 5;
            for iter = 1:nIter
                if size(pts,1) < 3, break; end
                idx = randperm(size(pts,1), 3);
                p = pts(idx,:);
                ax2 = p(1,1)^2+p(1,2)^2; bx2 = p(2,1)^2+p(2,2)^2; cx2 = p(3,1)^2+p(3,2)^2;
                D = 2*(p(1,1)*(p(2,2)-p(3,2)) + p(2,1)*(p(3,2)-p(1,2)) + p(3,1)*(p(1,2)-p(2,2)));
                if abs(D) < 1e-6, continue; end
                ux = (ax2*(p(2,2)-p(3,2)) + bx2*(p(3,2)-p(1,2)) + cx2*(p(1,2)-p(2,2))) / D;
                uy = (ax2*(p(3,1)-p(2,1)) + bx2*(p(1,1)-p(3,1)) + cx2*(p(2,1)-p(1,1))) / D;
                r  = sqrt((p(1,1)-ux)^2+(p(1,2)-uy)^2);
                if r < minR || r > maxR, continue; end
                dists = abs(sqrt((pts(:,1)-ux).^2+(pts(:,2)-uy).^2) - r);
                inliers = find(dists < distThresh);
                if numel(inliers) > numel(bestInliers)
                    bestInliers = inliers;
                    bestCircle = [ux, uy, r];
                end
            end
            if ~isempty(bestInliers)
                inPts = pts(bestInliers,:);
                out = insertMarker(baseRGB, inPts, 'circle', 'Color','green','Size',3);
                if ~isempty(bestCircle)
                    out = insertShape(out, 'circle', bestCircle, ...
                        'Color','red','LineWidth',2);
                end
            end
    end
end

function [out, midImg, leftOverride] = doStereo(leftImg, rightImg, op, param)
    out = []; midImg = []; leftOverride = [];
    if isempty(rightImg), return; end
    grayL = gray_safe(leftImg);
    grayR = gray_safe(rightImg);

    switch op
        case 'Epipolar Lines'
            try
                ptsL = detectSURFFeatures(grayL);
                ptsR = detectSURFFeatures(grayR);
                [featL, vL] = extractFeatures(grayL, ptsL);
                [featR, vR] = extractFeatures(grayR, ptsR);
                pairs = matchFeatures(featL, featR, 'MaxRatio', 0.7, 'Unique', true);
                if size(pairs,1) < 8
                    out = repmat(im2uint8(grayL),1,1,3);
                    midImg = repmat(im2uint8(grayR),1,1,3);
                    return;
                end
                matchedL = vL(pairs(:,1));
                matchedR = vR(pairs(:,2));
                % Use LMedS like the MATLAB docs example (variable name fLMedS).
                % More robust to mixed-quality SURF matches than RANSAC.
                [F, inliers] = estimateFundamentalMatrix(matchedL, matchedR, ...
                    'Method','LMedS','NumTrials',4000);
                inlPtsL = matchedL(inliers,:);
                inlPtsR = matchedR(inliers,:);
                % Cap number of lines drawn to keep visualisation clean.
                % F was estimated using ALL inliers — only the drawing is limited.
                maxDraw = 15;
                nInl = size(inlPtsL.Location,1);
                if nInl > maxDraw
                    rng(0);   % deterministic subset for repeatable display
                    drawIdx = randperm(nInl, maxDraw);
                else
                    drawIdx = 1:nInl;
                end
                drawnL = inlPtsL.Location(drawIdx,:);
                drawnR = inlPtsR.Location(drawIdx,:);
                rgbL = ternary(size(leftImg,3)==3, leftImg, repmat(grayL,1,1,3));
                % Draw matched source points on left
                for i = 1:size(drawnL,1)
                    loc = round(drawnL(i,:));
                    rgbL = insertShape(rgbL,'circle',[loc 5],'Color','green','LineWidth',2);
                end
                % MATLAB default ColorOrder cycle (same colors line() uses)
                colorCycle = uint8([ ...
                    0   114 189; ...   % blue
                    217 83  25;  ...   % orange
                    237 177 32;  ...   % yellow
                    126 47  142; ...   % purple
                    119 172 48;  ...   % green
                    77  190 238; ...   % cyan
                    162 20  47]);      % red
                % Epipolar lines in left image from right inliers
                epiL = epipolarLine(F', drawnR);
                ptsBL = lineToBorderPoints(epiL, size(grayL));
                for i = 1:size(ptsBL,1)
                    col = colorCycle(mod(i-1,7)+1,:);
                    rgbL = insertShape(rgbL,'line',ptsBL(i,:),'Color',col,'LineWidth',1);
                end
                % Middle box: plain right image in COLOR (no annotations)
                midImg = ternary(size(rightImg,3)==3, rightImg, repmat(grayR,1,1,3));
                out    = rgbL;   % left + epipolar lines (the visualization)
            catch ME
                out = repmat(im2uint8(grayL),1,1,3);
                midImg = repmat(im2uint8(grayR),1,1,3);
                disp(ME.message);
            end

        case 'Disparity Map'
            winSz = max(3, 2*floor(param/2)+1);
            gL = im2double(grayL);
            gR = im2double(grayR);
            [H, W] = size(gL);
            gR = imresize(gR, [H W]);
            % Middle box: show the ORIGINAL right image (color if available)
            midImg = ternary(size(rightImg,3)==3, rightImg, repmat(grayR,1,1,3));
            try
                dispMap = disparity(gL, gR, 'BlockSize', winSz, 'DisparityRange', [0 64]);
            catch
                % Fallback: manual SSD-based disparity for small images
                half = floor(winSz/2);
                maxDisp = 64;
                dispMap = zeros(H, W);
                for row = 1+half : H-half
                    for col = 1+half : W-half
                        patchL = gL(row-half:row+half, col-half:col+half);
                        bestSSD = inf; bestD = 0;
                        for d = 0:min(maxDisp, col-half-1)
                            c2 = col - d;
                            patchR = gR(row-half:row+half, c2-half:c2+half);
                            ssd = sum((patchL(:)-patchR(:)).^2);
                            if ssd < bestSSD, bestSSD=ssd; bestD=d; end
                        end
                        dispMap(row,col) = bestD;
                    end
                end
            end
            % Apply jet colormap so the depth map is colored like in the slides
            dispNorm = mat2gray(max(dispMap, 0));
            dispIdx = uint8(round(dispNorm * 255));
            cmap = jet(256);
            dispRGB = ind2rgb(dispIdx, cmap);
            out = im2uint8(dispRGB);

        case 'Scanline Matching'
            winSz = max(3, 2*floor(param/2)+1);
            half = floor(winSz/2);
            gL = im2double(grayL);
            gR = im2double(grayR);
            [Hi, Wi] = size(gL);
            if ~isequal(size(gR), [Hi Wi])
                gR = imresize(gR, [Hi Wi]);
                if size(rightImg,3)==3
                    rightImg = imresize(rightImg, [Hi Wi]);
                else
                    rightImg = imresize(rightImg, [Hi Wi]);
                end
            end
            % Auto-pick reference point via Harris corner (strongest, away from edges)
            refX = round(Wi/2); refY = round(Hi/2);
            try
                corners = detectHarrisFeatures(grayL, 'MinQuality', 0.05);
                locs = corners.Location;
                ok = locs(:,1) > 3*winSz & locs(:,1) < Wi - winSz & ...
                     locs(:,2) > 2*winSz & locs(:,2) < Hi - 2*winSz;
                validCorners = corners(ok);
                if validCorners.Count > 0
                    strongest = validCorners.selectStrongest(1);
                    refX = round(strongest.Location(1));
                    refY = round(strongest.Location(2));
                end
            catch
            end
            % Reference window from left image
            refWin = gL(refY-half:refY+half, refX-half:refX+half);
            % Search to the LEFT along scanline (positive disparity = shifted left in right image)
            maxDisp = min(80, refX - winSz - 1);
            costs = inf(1, maxDisp+1);
            for d = 0:maxDisp
                cx = refX - d;
                if cx-half < 1, continue; end
                cwin = gR(refY-half:refY+half, cx-half:cx+half);
                costs(d+1) = sum((refWin(:) - cwin(:)).^2);
            end
            [~, bestIdx] = min(costs);
            bestD = bestIdx - 1;
            bestX = refX - bestD;
            % Build display images
            rgbL_disp = ternary(size(leftImg,3)==3, leftImg, repmat(grayL,1,1,3));
            rgbR_disp = ternary(size(rightImg,3)==3, rightImg, repmat(grayR,1,1,3));
            % Purple scanline on both
            scanColor = uint8([200 30 200]);
            rgbL_disp = insertShape(rgbL_disp,'line',[1 refY Wi refY],'Color',scanColor,'LineWidth',1);
            rgbR_disp = insertShape(rgbR_disp,'line',[1 refY Wi refY],'Color',scanColor,'LineWidth',1);
            % Red reference window on left
            rgbL_disp = insertShape(rgbL_disp,'rectangle', ...
                [refX-half, refY-half, winSz, winSz],'Color','red','LineWidth',2);
            % Cyan candidate windows at 5 evenly-spaced disparities + best in red
            candDisps = round(linspace(0, maxDisp, 5));
            for d = candDisps
                cx = refX - d;
                if cx-half < 1 || cx+half > Wi, continue; end
                rgbR_disp = insertShape(rgbR_disp,'rectangle', ...
                    [cx-half, refY-half, winSz, winSz],'Color','cyan','LineWidth',1);
            end
            % Best match window (red)
            rgbR_disp = insertShape(rgbR_disp,'rectangle', ...
                [bestX-half, refY-half, winSz, winSz],'Color','red','LineWidth',2);
            % 2-box layout: left = ref + scanline, right (processed) = candidates + best match
            leftOverride = rgbL_disp;
            out = rgbR_disp;
            midImg = [];

        case 'Structure from Motion'
            % Reconstruct 3D point cloud from 2 views
            [Hi, Wi] = size(grayL);
            if ~isequal(size(grayR), [Hi Wi])
                grayR = imresize(grayR, [Hi Wi]);
                if size(rightImg,3)==3
                    rightImg = imresize(rightImg, [Hi Wi]);
                end
            end
            % SURF features + match
            ptsL = detectSURFFeatures(grayL);
            ptsR = detectSURFFeatures(grayR);
            [fL, vL] = extractFeatures(grayL, ptsL);
            [fR, vR] = extractFeatures(grayR, ptsR);
            pairs = matchFeatures(fL, fR, 'MaxRatio', 0.7, 'Unique', true);
            matchedL = vL(pairs(:,1));
            matchedR = vR(pairs(:,2));
            if size(pairs,1) < 8
                out = repmat(im2uint8(grayL),1,1,3);
                midImg = repmat(im2uint8(grayR),1,1,3);
                return;
            end
            % Approximate intrinsics (no calibration available)
            focalLength = max(Hi, Wi);
            principalPoint = [Wi/2, Hi/2];
            try
                intrinsics = cameraIntrinsics([focalLength focalLength], ...
                    principalPoint, [Hi Wi]);
            catch
                intrinsics = cameraIntrinsics(focalLength, principalPoint, [Hi Wi]);
            end
            points3D = []; inliers = [];
            try
                [E, inliers] = estimateEssentialMatrix(matchedL, matchedR, intrinsics);
                inlPtsL = matchedL(inliers);
                inlPtsR = matchedR(inliers);
                try
                    relPose = estrelpose(E, intrinsics, inlPtsL, inlPtsR);
                    camMat1 = cameraProjection(intrinsics, rigidtform3d());
                    camMat2 = cameraProjection(intrinsics, pose2extr(relPose));
                catch
                    [relOrient, relLoc] = relativeCameraPose(E, intrinsics, ...
                        inlPtsL, inlPtsR);
                    camMat1 = cameraMatrix(intrinsics, eye(3), [0 0 0]);
                    [R, t] = cameraPoseToExtrinsics(relOrient, relLoc);
                    camMat2 = cameraMatrix(intrinsics, R, t);
                end
                points3D = triangulate(inlPtsL, inlPtsR, camMat1, camMat2);
            catch ME
                disp(['SfM failed: ' ME.message]);
            end
            % Filter outlier 3D points (typical: clip to ~3-sigma)
            if ~isempty(points3D)
                z = points3D(:,3);
                keep = z > 0 & z < quantile(z,0.95) & isfinite(z);
                points3D = points3D(keep,:);
            end
            % Sample colors at the inlier image points to color the cloud
            ptColors = uint8([]);
            if ~isempty(points3D) && ~isempty(inliers)
                rgbSrc = ternary(size(leftImg,3)==3, leftImg, repmat(grayL,1,1,3));
                locs = round(matchedL(inliers).Location);
                locs = locs(keep,:);
                ptColors = zeros(size(points3D,1), 3, 'uint8');
                for i = 1:size(locs,1)
                    cy = max(1, min(Hi, locs(i,2)));
                    cx = max(1, min(Wi, locs(i,1)));
                    ptColors(i,:) = squeeze(rgbSrc(cy,cx,:))';
                end
            end
            % Render 3D point cloud offscreen → image
            tmpFig = figure('Visible','off','Color',[0.1 0.1 0.12], ...
                'Position',[100 100 900 700], 'MenuBar','none','ToolBar','none');
            tmpAx = axes('Parent',tmpFig);
            if ~isempty(points3D)
                if ~isempty(ptColors)
                    scatter3(tmpAx, points3D(:,1), points3D(:,2), points3D(:,3), ...
                        30, double(ptColors)/255, 'filled');
                else
                    scatter3(tmpAx, points3D(:,1), points3D(:,2), points3D(:,3), ...
                        30, 'g', 'filled');
                end
                xlabel(tmpAx,'X','Color','w'); ylabel(tmpAx,'Y','Color','w'); zlabel(tmpAx,'Z','Color','w');
                title(tmpAx, sprintf('SfM 3D Point Cloud  (%d points)', size(points3D,1)), ...
                    'Color','w','FontSize',13);
                tmpAx.Color = [0.1 0.1 0.12];
                tmpAx.XColor = 'w'; tmpAx.YColor='w'; tmpAx.ZColor='w';
                grid(tmpAx,'on');
                tmpAx.GridColor = [0.4 0.4 0.4];
                axis(tmpAx,'vis3d'); axis(tmpAx,'tight');
                view(tmpAx, 30, 25);
            else
                text(tmpAx,0.5,0.5,'SfM failed: too few matches', ...
                    'Color','w','HorizontalAlignment','center','FontSize',14);
                axis(tmpAx,'off');
            end
            drawnow;
            frame = getframe(tmpAx);
            close(tmpFig);
            % Outputs: original = left, middle = right, processed = 3D cloud
            midImg = ternary(size(rightImg,3)==3, rightImg, repmat(grayR,1,1,3));
            out = frame.cdata;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  KERNEL PANEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function updateKernelPanel(fig, op, param, nLP, nHP)
    d = fig.UserData;
    imgSz = size(d.origImg);
    [K,desc,txt] = getKernelInfo(op, param, nLP, nHP, imgSz);
    d.h.lblDesc.Text = desc;
    ax = d.h.axKern;
    cla(ax);

    if isempty(K)
        ax.Title.String='';
        d.h.txtKern.Value={'No discrete kernel for this operation.'};
        fig.UserData=d; return;
    end

    [nr,nc]=size(K);
    cmap=divCmap(256);
    mn=min(K(:)); mx=max(K(:));
    Kn=ternary(mx>mn,(K-mn)./(mx-mn),ones(size(K))*0.5);
    cidx=max(1,min(256,round(Kn*255)+1));
    image(ax, reshape(cmap(cidx(:),:),[nr nc 3]));
    axis(ax,'equal','tight');
    ax.XTick=[]; ax.YTick=[];
    ax.XGrid='on'; ax.YGrid='on';
    ax.GridColor=[0.3 0.3 0.3]; ax.GridAlpha=1; ax.TickLength=[0 0];

    if nr<=15 && nc<=15
        hold(ax,'on');
        for r=1:nr
            for c=1:nc
                col=cmap(cidx(r,c),:);
                bright=0.299*col(1)+0.587*col(2)+0.114*col(3);
                tcol=ternary(bright>0.5,[0 0 0],[1 1 1]);
                v=K(r,c);
                if v==round(v), s=sprintf('%d',v); else, s=sprintf('%.3f',v); end
                text(ax,c,r,s,'HorizontalAlignment','center', ...
                    'VerticalAlignment','middle','FontSize',11, ...
                    'FontWeight','bold','Color',tcol);
            end
        end
        hold(ax,'off');
    end
    ax.Title.String=sprintf('Kernel / Mask  (%d × %d)',nr,nc);
    ax.Title.Color=[0.8 0.9 1.0]; ax.Title.FontSize=11;
    d.h.txtKern.Value=txt;
    fig.UserData=d;
end

% ── getKernelInfo ─────────────────────────────────────────────────────────
function [K,desc,txt] = getKernelInfo(op, param, nLP, nHP, imgSz)
    K=[]; desc=''; txt={''};
    switch op

        %% Enhancement
        case 'Brightness'
            desc='Brightness: out=clamp(I+offset) — pixel-wise, no kernel';
            txt={'BRIGHTNESS ADJUSTMENT',sp(),'', ...
                'No convolution kernel — pixel-wise operation.', ...
                sprintf('Offset     :  %+.3f', param),'', ...
                'Formula    :  out(x,y) = clamp( I(x,y) + offset, 0, 1 )','', ...
                'Range   -1.0 → black  |  0.0 → no change  |  +1.0 → white', ...
                'Applied per channel for colour images.','', ...
                'Ref: DIP Ch3 – Gray-level transformation functions'};

        case 'Histogram Equalization'
            desc='Histogram Equalisation: T(r)=(L-1)·CDF(r) — no kernel';
            txt={'HISTOGRAM EQUALISATION',sp(),'', ...
                'No convolution kernel — intensity remapping via CDF.','', ...
                'Transform (DIP Ch3 Eq.3.3-8):', ...
                '  s_k = (L-1) · sum_{j=0}^{k} n_j / n','', ...
                '  n_j = pixel count at gray level r_j', ...
                '  n   = total pixels,  L = 256 levels','', ...
                'Colour: converts RGB→HSV, equalises V only, then back.', ...
                'Ref: DIP Ch3 p.17'};

        %% Spatial Filtering
        case 'Laplacian 1st'
            K=[0 -1 0;-1 4 -1;0 -1 0];
            desc='Laplacian 4-connectivity — positive centre, add back (DIP Ch3 p.41-43)';
            txt=kText('LAPLACIAN  4-connectivity  (DIP Ch3 p.41-43)',K,{ ...
                'Type    :  2nd-derivative edge detector (4 neighbours)', ...
                'Formula :  ∇²f = f(x+1,y)+f(x-1,y)+f(x,y+1)+f(x,y-1)−4f(x,y)','', ...
                'Sharpening (positive centre → add back):', ...
                '  g(x,y) = f(x,y) + ∇²f(x,y)   [DIP Ch3 p.41]','', ...
                'Sum of coefficients = 0  (zero DC response).', ...
                'Middle axes: raw Laplacian response.'});

        case 'Laplacian 2nd'
            K=[-1 -1 -1;-1 8 -1;-1 -1 -1];
            desc='Laplacian 8-connectivity — includes diagonals (DIP Ch3 p.42)';
            txt=kText('LAPLACIAN  8-connectivity  (DIP Ch3 p.42-44)',K,{ ...
                'Type    :  2nd-derivative edge detector (8 neighbours)', ...
                'Centre  :  +8','', ...
                'g(x,y) = f(x,y) + ∇²f(x,y)   [DIP Ch3 p.41]','', ...
                'Stronger response than 4-connectivity.', ...
                'Sum of coefficients = 0.'});

        case 'Boosting'   % [F3] A >= 1
            A=param; K=[-1 -1 -1;-1 (A+8) -1;-1 -1 -1];
            desc=sprintf('High-Boost (DIP Ch3 p.45): A=%.2f≥1, centre=A+8=%.2f',A,A+8);
            txt=kText(sprintf('HIGH-BOOST FILTERING  A=%.2f  (DIP Ch3 p.45-46)',A),K,{ ...
                'f_hb = A·f − f_blurred   [DIP Ch3 p.45]', ...
                'Single-pass kernel:  K = [-1 -1 -1; -1 A+8 -1; -1 -1 -1]','', ...
                sprintf('A = %.4f   →   centre = %.4f',A,A+8),'', ...
                'CONSTRAINT: A ≥ 1  (textbook definition)', ...
                '  A=1 → classic unsharp masking', ...
                '  A>1 → more original image retained', ...
                '  A=0 → pure Laplacian (NOT high-boost)','', ...
                'Middle axes: Laplacian-only response for comparison.'});

        case 'Box Filter'
            ks=max(1,2*floor(param/2)+1);
            K=ones(ks)/ks^2;
            desc=sprintf('Box (Mean) Filter %d×%d — equal weights 1/k²  (DIP Ch3 p.34)',ks,ks);
            txt=kText(sprintf('BOX FILTER  %d×%d  (DIP Ch3 p.34)',ks,ks),K,{ ...
                'Type    :  Low-pass averaging filter', ...
                sprintf('Weight  :  1/%d = %.6f per cell',ks^2,1/ks^2),'', ...
                'g(x,y) = (1/mn)·sum f(x+s,y+t)   [DIP Ch3 Eq.3.5-1]','', ...
                'Simple but causes box-ringing artefacts.'});

        case 'Weighted Average'
            % [F4] FIX: exact textbook kernel for ksize=3
            ks=max(1,2*floor(param/2)+1);
            if ks==3
                K=(1/16)*[1 2 1;2 4 2;1 2 1];  % exact DIP Ch3 Fig.3.34b
            else
                sig=max(ks/4,0.5);
                [gx,gy]=meshgrid(-(ks-1)/2:(ks-1)/2);
                K=exp(-(gx.^2+gy.^2)/(2*sig^2)); K=K/sum(K(:));
            end
            sig=max(ks/4,0.5);
            desc=sprintf('Gaussian Weighted Avg σ=%.2f, %d×%d  (DIP Ch3 p.34)',sig,ks,ks);
            txt=kText(sprintf('GAUSSIAN WEIGHTED AVG  σ=%.2f  %d×%d  (DIP Ch3 p.34)',sig,ks,ks),K,{ ...
                sprintf('σ = %.4f  (= ksize/4, min 0.5)',sig),'', ...
                'For ksize=3: EXACT textbook kernel (DIP Ch3 Fig.3.34b):', ...
                '  (1/16) × [1 2 1; 2 4 2; 1 2 1]','', ...
                'For ksize>3: sampled Gaussian, normalised sum=1.','', ...
                'NOTE: app uses imgaussfilt() for actual processing.', ...
                'Displayed kernel matches textbook for ksize=3.'});

        case 'Median Filter'
            ks=max(1,2*floor(param/2)+1);
            desc=sprintf('Median Filter %d×%d — non-linear rank filter, no kernel  (DIP Ch3 p.37)',ks,ks);
            txt={sprintf('MEDIAN FILTER  %d×%d  (DIP Ch3 p.37)',ks,ks),sp(),'', ...
                'Type      :  Non-linear order-statistics filter  (NO kernel)', ...
                sprintf('Window    :  %d×%d pixels',ks,ks),'', ...
                'Algorithm : sort neighbourhood values → output median.', ...
                '  3×3 → 9 values  → 5th largest', ...
                '  5×5 → 25 values → 13th largest','', ...
                'Effect    :  Excellent salt-and-pepper noise removal.', ...
                '             Better edge preservation than linear filters.','', ...
                'Applied per colour channel independently.'};

        case 'Sobel H'
            K=[-1 -2 -1;0 0 0;1 2 1];
            desc='Sobel Gy — horizontal edges, ×2 centre row  (DIP Ch3 p.47)';
            txt=kText('SOBEL  Gy  —  HORIZONTAL EDGES  (DIP Ch3 p.47)',K,{ ...
                '∇f ≈ |(z7+2z8+z9)−(z1+2z2+z3)|   [DIP Ch3 p.47]','', ...
                'Centre row weight ×2 for smoothing (vs Prewitt ×1).', ...
                'Sum of coefficients = 0.','', ...
                'THREE-BOX DISPLAY:', ...
                '  Middle: Normalized gradient (shows directional response)', ...
                '  Right:  Absolute gradient magnitude (edge strength)'});

        case 'Sobel V'
            K=[-1 0 1;-2 0 2;-1 0 1];
            desc='Sobel Gx — vertical edges, ×2 centre column  (DIP Ch3 p.47)';
            txt=kText('SOBEL  Gx  —  VERTICAL EDGES  (DIP Ch3 p.47)',K,{ ...
                '∇f ≈ |(z3+2z6+z9)−(z1+2z4+z7)|   [DIP Ch3 p.47]','', ...
                'Gx = transpose of Gy.  Sum = 0.','', ...
                'THREE-BOX DISPLAY:', ...
                '  Middle: Normalized gradient (shows directional response)', ...
                '  Right:  Absolute gradient magnitude (edge strength)'});

        case 'Prewitt'
            % Kernel visualization hidden for Prewitt because it uses TWO kernels
            % (Kh and Kv), and showing only one would be misleading
            K=[];  % Return empty to hide kernel heatmap
            desc='Prewitt edge detector: uses 2 kernels (Kh+Kv) → magnitude √(Gh²+Gv²)  (DIP Ch3 p.47)';
            txt={'PREWITT EDGE DETECTOR  (DIP Ch3 p.47)',sp(),'', ...
                'Uses TWO kernels (no single kernel visualization):', ...
                '','', ...
                '  Kh (horizontal / Gy):    Kv (vertical / Gx):', ...
                '   -1  -1  -1              -1   0   1', ...
                '    0   0   0              -1   0   1', ...
                '    1   1   1              -1   0   1','', ...
                'Combined result: G = sqrt(Gh²+Gv²)  or  ∇f ≈ |Gh|+|Gv|','', ...
                'vs Sobel: uniform weights — no ×2 on centre row/col.', ...
                'Processed on greyscale channel, result shows edge magnitude.'};

        %% Frequency Filtering
        case 'Ideal LP'
            K=fPrev(op,param,nLP,nHP,imgSz);
            desc=sprintf('Ideal LP — D0=%.0fpx  H=1 if D≤D0 else 0  (DIP Ch4 p.24-27)',param);
            txt=fText('IDEAL LOW-PASS FILTER  (DIP Ch4 p.24-27)',param,{ ...
                'H(u,v) = 1  if D(u,v) ≤ D0  (pass)', ...
                'H(u,v) = 0  if D(u,v) >  D0  (block)','', ...
                'D(u,v) = sqrt[(u−M/2)² + (v−N/2)²]   [DIP Ch4 p.24]','', ...
                'Artefact: Gibbs ringing from abrupt cutoff.'});

        case 'Ideal HP'
            K=fPrev(op,param,nLP,nHP,imgSz);
            desc=sprintf('Ideal HP — D0=%.0fpx  H=0 if D≤D0 else 1  (DIP Ch4 p.42)',param);
            txt=fText('IDEAL HIGH-PASS FILTER  (DIP Ch4 p.42)',param,{ ...
                'H_hp = 1 − H_lp   [DIP Ch4 p.39]', ...
                'H(u,v) = 0  if D ≤ D0  (block)', ...
                'H(u,v) = 1  if D >  D0  (pass)','', ...
                'Complement of Ideal LP. Same ringing artefact.'});

        case 'Butterworth LP'
            K=fPrev(op,param,nLP,nHP,imgSz);
            desc=sprintf('Butterworth LP — D0=%.0fpx, n=%d  (DIP Ch4 p.29)',param,nLP);
            txt=fText(sprintf('BUTTERWORTH LOW-PASS  n=%d  (DIP Ch4 p.29-32)',nLP),param,{ ...
                sprintf('H(u,v) = 1 / (1+[D/D0]^{2n})   n=%d',nLP),'', ...
                '  n=1  : gradual rolloff, no ringing', ...
                '  n=2  : mild ringing, small negatives', ...
                '  n→∞ : approaches Ideal LP','', ...
                'H=0.5 at D=D0  (−3dB cutoff point)'});

        case 'Butterworth HP'
            K=fPrev(op,param,nLP,nHP,imgSz);
            desc=sprintf('Butterworth HP — D0=%.0fpx, n=%d  (DIP Ch4 p.43)',param,nHP);
            txt=fText(sprintf('BUTTERWORTH HIGH-PASS  n=%d  (DIP Ch4 p.43)',nHP),param,{ ...
                sprintf('H(u,v) = 1 / (1+[D0/D]^{2n})   n=%d',nHP),'', ...
                'D0 in numerator (inverted vs LP).', ...
                'Smooth low-freq attenuation.'});

        case 'Gaussian LP'
            K=fPrev(op,param,nLP,nHP,imgSz);
            desc=sprintf('Gaussian LP — D0=%.0fpx  H=exp(−D²/2D0²)  (DIP Ch4 p.33)',param);
            txt=fText('GAUSSIAN LOW-PASS  (DIP Ch4 p.33-35)',param,{ ...
                'H(u,v) = exp(−D(u,v)² / (2·D0²))', ...
                'D0=σ (std dev in freq domain)  H≈0.607 at D=D0','', ...
                'FT pair: H and h both Gaussian → no Gibbs ringing.', ...
                'Ref: DIP Ch4 p.21'});

        case 'Gaussian HP'
            K=fPrev(op,param,nLP,nHP,imgSz);
            desc=sprintf('Gaussian HP — D0=%.0fpx  H=1−exp(−D²/2D0²)  (DIP Ch4 p.44)',param);
            txt=fText('GAUSSIAN HIGH-PASS  (DIP Ch4 p.44)',param,{ ...
                'H(u,v) = 1 − exp(−D(u,v)² / (2·D0²))', ...
                'Complement of Gaussian LP.  No Gibbs ringing.','', ...
                'Smoothest of the three HP filter types.'});

        %% Color Space
        case 'RGB to HSI'
            desc='RGB→HSI: non-linear per-pixel — no kernel';
            txt={'RGB → HSI CONVERSION  (DIP Colour Chapter)',sp(),'', ...
                'θ = arccos( 0.5[(R-G)+(R-B)] / sqrt[(R-G)²+(R-B)(G-B)] )', ...
                'H = θ if B≤G;   H = 360°-θ if B>G;   H = H/360°', ...
                'S = 1 − 3·min(R,G,B)/(R+G+B)', ...
                'I = (R+G+B)/3','', ...
                'Displayed as pseudo-RGB: [H, S, I]'};

        case 'RGB to Lab'
            desc='RGB→CIE L*a*b*: perceptually uniform — no kernel';
            txt={'RGB → CIE L*a*b* CONVERSION',sp(),'', ...
                'Step 1: RGB → XYZ  (ICC matrix)', ...
                'Step 2: XYZ → L*a*b*  (cube-root non-linearity)','', ...
                'L* [0,100]   → ÷100', ...
                'a* [-128,127] → +128/255', ...
                'b* [-128,127] → +128/255','', ...
                'Perceptually uniform: Euclidean distance ≈ ΔE'};

        case 'RGB to YCbCr'
            % [F5] True BT.601 float coefficients
            K=[ 0.257  0.504  0.098;
               -0.148 -0.291  0.439;
                0.439 -0.368 -0.071];
            desc='RGB→YCbCr: BT.601 matrix [Y;Cb;Cr]=M·[R;G;B]+[16;128;128]';
            txt=kText('RGB→YCbCr  BT.601 FLOAT MATRIX',K,{ ...
                '[Y; Cb; Cr] = M·[R; G; B] + [16; 128; 128]','', ...
                'Y  =  0.257R + 0.504G + 0.098B + 16', ...
                'Cb = −0.148R − 0.291G + 0.439B + 128', ...
                'Cr =  0.439R − 0.368G − 0.071B + 128','', ...
                'Shown: TRUE BT.601 floating-point coefficients.', ...
                'Separates luminance (Y) from chrominance (Cb,Cr).', ...
                'Used in JPEG, MPEG, broadcasting.'});

        %% Pyramids
        case {'Gaussian Reduce','Gaussian Expand','Laplacian Level'}
            h1 = [1 4 6 4 1]/16;
            K = h1' * h1;
            desc = sprintf('%s — 5-tap Gaussian kernel used by impyramid', op);
            txt = kText(sprintf('%s  (Gaussian Pyramid)', upper(op)), K, { ...
                'impyramid uses a 5-tap Gaussian separable filter:', ...
                '  h = [1 4 6 4 1] / 16', ...
                'Applied as: K = h'' * h  (2-D outer product)', ...
                '', ...
                'Reduce: apply filter then subsample 2×', ...
                'Expand: upsample 2× then apply filter', ...
                'Laplacian = original − expand(reduce(image))', ...
                'Ref: Burt & Adelson 1983'});

        %% Template Matching
        case 'Correlation'
            desc = 'Correlation: h[m,n] = Σ g[k,l]·f[m+k,n+l]  — template as filter kernel';
            txt = {'CORRELATION (Method 0)', sp(), '', ...
                'h[m,n] = Σ_{k,l} g[k,l] · f[m+k, n+l]', '', ...
                '  g = template (used as filter kernel)', ...
                '  f = image', '', ...
                'Implemented as: imfilter(image, rot90(template,2))', ...
                'Output: bright regions = high dot-product with template.', '', ...
                'Problem: response depends on absolute image brightness,', ...
                'not just pattern similarity → unreliable matching.'};

        case 'Zero-mean Correlation'
            desc = 'Zero-mean correlation: h[m,n] = Σ (g[k,l]−ḡ)·f[m+k,n+l]';
            txt = {'ZERO-MEAN CORRELATION (Method 1)', sp(), '', ...
                'h[m,n] = Σ_{k,l} (f[k,l] − f̄) · g[m+k, n+l]', '', ...
                '  f = template,  f̄ = mean of template', ...
                '  g = image', '', ...
                'Subtracting the mean makes the template zero-mean,', ...
                'removing DC bias and improving sensitivity to edges/texture.', '', ...
                'Still sensitive to local image brightness variations.', ...
                'Peak of response → best match location.'};

        case 'Sum Square Difference'
            desc = 'SSD: Σ(template−patch)²  — minimum = best match';
            txt = {'SUM OF SQUARED DIFFERENCES (SSD)', sp(), '', ...
                'SSD(m,n) = Σ_{k,l} (f[k,l] − g[m+k,n+l])²', '', ...
                'Efficient decomposition:', ...
                '  SSD = Σf² − 2·corr(f,g) + local_energy(g)', '', ...
                '  Σf²         = constant (sum of template²)', ...
                '  corr(f,g)   = conv2(image, template, ''valid'')', ...
                '  local_energy = conv2(image², ones(th,tw), ''valid'')', '', ...
                'Display: inverted (bright = low SSD = good match).', ...
                'Minimum of SSD map → best match location.'};

        case 'Normalized Cross Correlation'
            desc = 'NCC: C(u,v) = Σ[(f−f̄)(t−t̄)] / (σ_f · σ_t)  ∈ [−1, 1]';
            txt = {'NORMALIZED CROSS-CORRELATION (NCC)', sp(), '', ...
                'normxcorr2(template, image) returns C ∈ [−1, 1]', '', ...
                'C(u,v) = Σ[(f(x,y)−f̄)(t(x,y)−t̄)] / (σ_f · σ_t)', '', ...
                '  f̄ = mean of image patch under template', ...
                '  t̄ = mean of template', ...
                '  σ  = std dev (zero-variance → C=0)', '', ...
                'Invariant to linear changes in brightness/contrast.', ...
                'Most robust of the four methods.', ...
                'Peak of C → best match location.'};

        %% Filter Banks
        case 'DoG Bank'
            pairs = [1 2; 2 3; 3 5; 1 3; 2 5; 1 5];
            idx = max(1, min(6, round(param)));
            s1 = pairs(idx,1); s2 = pairs(idx,2);
            ksz = 2*ceil(3*s2)+1;
            [gx,gy] = meshgrid(-(ksz-1)/2:(ksz-1)/2);
            g1 = exp(-(gx.^2+gy.^2)/(2*s1^2)); g1=g1/sum(g1(:));
            g2 = exp(-(gx.^2+gy.^2)/(2*s2^2)); g2=g2/sum(g2(:));
            K = g1 - g2;
            desc = sprintf('DoG Bank filter #%d: σ1=%.0f, σ2=%.0f', idx, s1, s2);
            txt = kText(sprintf('DOG FILTER BANK  #%d  (σ1=%d, σ2=%d)', idx, s1, s2), K, { ...
                'DoG ≈ scale-normalised LoG (Mexican hat)', ...
                sprintf('σ pairs: (1,2) (2,3) (3,5) (1,3) (2,5) (1,5) — index=%d', idx), ...
                '', 'DoG = G(σ1) − G(σ2),  σ1 < σ2', ...
                'Bandpass: passes frequencies between the two scales.', ...
                'Ref: Marr & Hildreth 1980; Lowe SIFT 2004'});

        case 'Gabor Bank'
            idx = max(1,min(6,round(param)));
            theta = (idx-1)*30;
            wavelength = 8;
            ksz = 21;
            [gx,gy] = meshgrid(-(ksz-1)/2:(ksz-1)/2);
            sigma_g = wavelength/pi*sqrt(log(2)/2)*(2+1)/(2-1);
            K = exp(-0.5*(gx.^2+gy.^2)/sigma_g^2) .* ...
                cos(2*pi/wavelength*(gx*cosd(theta)+gy*sind(theta)));
            desc = sprintf('Gabor Bank filter #%d: θ=%d°, λ=8', idx, theta);
            txt = kText(sprintf('GABOR FILTER BANK  #%d  θ=%d°', idx, theta), K, { ...
                sprintf('Orientation θ = %d°  (0°,30°,60°,90°,120°,150°)', theta), ...
                'Wavelength λ = 8 px', ...
                '', 'g(x,y) = exp(−(x²+y²)/2σ²) · cos(2π/λ · (x·cosθ + y·sinθ))', ...
                'Joint spatial + frequency localisation (Gabor uncertainty principle).', ...
                'Used in texture analysis, face recognition.'});

        %% Edge Detection
        case 'Sobel (edge)'
            K = [-1 -2 -1; 0 0 0; 1 2 1];
            desc = 'Sobel edge: MATLAB edge() with Sobel operator + hysteresis thresholding';
            txt = kText('SOBEL EDGE DETECTION  (edge function)', K, { ...
                'Uses MATLAB edge(I,''Sobel'',thresh)', ...
                'Threshold=0 → auto (3σ of gradient histogram)', ...
                '', 'Gx = [-1 0 1;-2 0 2;-1 0 1],  Gy = Gx''', ...
                'Output: binary edge map (logical)', ...
                'Middle: gradient magnitude √(Gx²+Gy²)'});

        case 'Prewitt (edge)'
            K = [-1 -1 -1; 0 0 0; 1 1 1];
            desc = 'Prewitt edge: MATLAB edge() with Prewitt operator + thresholding';
            txt = kText('PREWITT EDGE DETECTION  (edge function)', K, { ...
                'Uses MATLAB edge(I,''Prewitt'',thresh)', ...
                '', 'Uniform weights (vs Sobel ×2 centre).'});

        case 'Roberts'
            K = [1 0; 0 -1];
            desc = 'Roberts cross-gradient: 2×2 diagonal differences';
            txt = kText('ROBERTS EDGE DETECTION', K, { ...
                'Two 2×2 kernels:', ...
                '  K1 = [1 0; 0 -1]  (shown)', ...
                '  K2 = [0 1; -1 0]', ...
                '', 'G = sqrt(K1*I² + K2*I²)', ...
                'Smallest and fastest edge detector.  Sensitive to noise.'});

        case 'LoG'
            sig = max(0.5, param);
            ksz = 2*ceil(3*sig)+1;
            [gx,gy] = meshgrid(-(ksz-1)/2:(ksz-1)/2);
            r2 = gx.^2+gy.^2;
            K = -(1/(pi*sig^4))*(1-r2/(2*sig^2)).*exp(-r2/(2*sig^2));
            desc = sprintf('Laplacian of Gaussian σ=%.2f — zero crossings = edges', sig);
            txt = kText(sprintf('LAPLACIAN OF GAUSSIAN  σ=%.2f', sig), K, { ...
                'LoG(x,y) = −(1/πσ⁴)(1−r²/2σ²)exp(−r²/2σ²)', ...
                sprintf('σ = %.2f  (controls scale / blur)', sig), ...
                '', 'Edges = zero-crossings of LoG response.', ...
                'More isotropic than Sobel/Prewitt.', ...
                'Ref: Marr & Hildreth 1980'});

        case 'Canny'
            desc = sprintf('Canny edge detector σ=%.2f — optimal SNR, localisation, uniqueness', param);
            txt = {'CANNY EDGE DETECTOR  (DIP + Canny 1986)', sp(), '', ...
                sprintf('σ = %.2f  (Gaussian smoothing before gradient)', param), '', ...
                'Steps:', ...
                '  1. Smooth with Gaussian (σ)', ...
                '  2. Compute gradient magnitude & direction', ...
                '  3. Non-maximum suppression (thin edges)', ...
                '  4. Hysteresis thresholding (high+low)', '', ...
                'Two thresholds: strong edges kept, weak edges kept', ...
                'only if connected to strong edges.', ...
                'Generally the most robust edge detector.'};

        %% Corner Detection
        case 'Harris Corners'
            K = fspecial('Gaussian', 5, 5/3);
            desc = sprintf('Harris–Stephens corners: R=det(M)−k·tr(M)²  MinQuality=%.3f', param);
            txt = kText('HARRIS CORNER DETECTOR  (Harris & Stephens 1988)', K, { ...
                'Structure tensor M = Σw(x,y) [Ix² IxIy; IxIy Iy²]', ...
                'w(x,y) = Gaussian window (shown)', '', ...
                'Corner response: R = det(M) − k·tr(M)²,  k=0.04', ...
                '  R >> 0 → corner', ...
                '  R << 0 → edge', ...
                '  R ≈ 0  → flat region', '', ...
                sprintf('MinQuality = %.3f (fraction of max R)', param), ...
                'selectStrongest(200) shown.'});

        case 'SIFT Keypoints'
            desc = sprintf('SIFT keypoints: DoG scale-space extrema, N=%d strongest', round(param));
            txt = {'SIFT KEYPOINTS  (Lowe 2004)', sp(), '', ...
                'Scale-Invariant Feature Transform:', ...
                '  1. Build DoG scale-space pyramid', ...
                '  2. Detect local extrema across scales', ...
                '  3. Refine subpixel location (Taylor expansion)', ...
                '  4. Filter low-contrast & edge responses', '', ...
                sprintf('Showing %d strongest keypoints (by scale/contrast)', round(param)), '', ...
                'Invariant to scale, rotation, illumination.', ...
                'Ref: Lowe IJCV 2004'};

        %% Blob Detection
        case 'DoG Blobs'
            desc = 'DoG scale-space blob detector: local maxima of |G(σ₁)−G(σ₂)| across σ=[1,2,4,8]';
            txt = {'DOG BLOB DETECTION  (Lowe 2004 / Marr & Hildreth 1980)', sp(), '', ...
                'DoG(σ) ≈ σ²·∇²G  (scale-normalised)', '', ...
                'Scale pyramid: σ = [1, 2, 4, 8]', ...
                'DoG layers: G(1)−G(2), G(2)−G(4), G(4)−G(8)', '', ...
                'Blob centre = local maximum of |DoG| above threshold.', ...
                'Circle radius drawn proportional to detection scale.', ...
                'Cyan circles = detected blobs.', '', ...
                'Threshold slider: lower → more blobs (noisier),', ...
                '                  higher → fewer blobs (stronger only).', '', ...
                'Ref: Lowe IJCV 2004; Lindeberg scale-space theory'};

        case 'LoG Blobs'
            desc = 'LoG scale-space blob detector: σ²·∇²G responses at σ=[1,2,4,8]';
            txt = {'LOG BLOB DETECTION  (Marr & Hildreth 1980)', sp(), '', ...
                'Scale-normalised LoG:', ...
                '  LoG_norm(σ) = σ² · ∇²G(σ)', ...
                '  ∇²G(σ) = −(1/πσ⁴)(1−r²/2σ²)exp(−r²/2σ²)', '', ...
                'Scale pyramid: σ = [1, 2, 4, 8]', '', ...
                'Blob centre = local maximum of |LoG_norm| above threshold.', ...
                'Yellow circles = detected blobs.', '', ...
                'LoG gives more isotropic blob response than DoG.', ...
                'DoG ≈ LoG (computationally cheaper in SIFT pipeline).', '', ...
                'Ref: Marr & Hildreth 1980; Lindeberg 1994'};

        %% HoG
        case 'HoG Visualization'
            cs = snapHoGCell(param);
            desc = sprintf('HoG: gradient orientation histograms per %d×%d cell (Dalal & Triggs 2005)', cs, cs);
            txt = {'HISTOGRAM OF ORIENTED GRADIENTS  (Dalal & Triggs, CVPR 2005)', sp(), '', ...
                sprintf('Cell size: %d × %d px   (8 orientation bins)', cs, cs), '', ...
                'Algorithm:', ...
                '  1. Compute gradient magnitude & orientation at each pixel', ...
                '  2. Divide image into cells of size CxC pixels', ...
                '  3. Bin orientations [0°,180°) into 9 bins per cell', ...
                '  4. Group cells into overlapping blocks; L2-normalise', '', ...
                'Left: Gradient magnitude map', ...
                'Right: HoG glyph visualisation', ...
                '       Each line = dominant gradient orientation in cell,', ...
                '       length ∝ gradient magnitude.', '', ...
                'Applications: pedestrian detection (HOG+SVM), object recognition.', ...
                'Ref: Dalal & Triggs CVPR 2005'};

        case 'HoG Cell Grid'
            cs = snapHoGCell(param);
            desc = sprintf('HoG Cell Grid: same HoG glyphs as Visualization, cell size %d×%d', cs, cs);
            txt = {'HOG CELL GRID  (same as HoG Visualization)', sp(), '', ...
                sprintf('Cell size: %d × %d px', cs, cs), '', ...
                'Shows the cell-by-cell glyph overlay.', ...
                'Change cell size slider to see effect on descriptor resolution.', ...
                '  Small cells → fine spatial detail, larger descriptor vector', ...
                '  Large cells → coarser spatial detail, more robust to noise'};

        %% Hough Transform
        case 'Hough Lines'
            desc = sprintf('Hough Line Transform: detect top %d line(s) via accumulator peaks', round(param));
            txt = {'HOUGH LINE TRANSFORM  (Hough 1962 / Duda & Hart 1972)', sp(), '', ...
                'Parametric representation: ρ = x·cos(θ) + y·sin(θ)', '', ...
                'Algorithm:', ...
                '  1. Run Canny edge detection on image', ...
                '  2. Each edge pixel votes for all (ρ,θ) lines through it', ...
                '  3. Accumulator H[ρ,θ] counts votes', ...
                '  4. Find N peaks in H (= N most prominent lines)', ...
                '  5. houghlines() converts peaks to line segments', '', ...
                sprintf('N Peaks slider: number of lines to detect = %d', round(param)), '', ...
                'Middle box: Hough accumulator space (bright = many votes)', ...
                'Right box:  Detected lines overlaid in green.', '', ...
                'Tip: Gaussian pre-processing reduces noise votes.', ...
                'Ref: MATLAB hough(), houghpeaks(), houghlines()'};

        case 'Hough Circles'
            desc = sprintf('Hough Circle Transform: detect circles via imfindcircles, sensitivity=%.2f', param/100);
            txt = {'HOUGH CIRCLE TRANSFORM  (Hough 3D accumulator)', sp(), '', ...
                'Circle equation: (x−a)² + (y−b)² = r²', '', ...
                'For each edge pixel (x,y) and each radius r:', ...
                '  Votes for center (a,b) = (x ± r·cos θ, y ± r·sin θ)', ...
                '  Accumulator H[a,b,r] is a 3D space', '', ...
                'MATLAB imfindcircles() implements this efficiently.', '', ...
                sprintf('Sensitivity slider: %.2f  (0.80=strict → 1.00=permissive)', param/100), ...
                '  Low sensitivity → only strong circular features', ...
                '  High sensitivity → more circles but more false positives', '', ...
                'Middle box: Canny edge image used for voting', ...
                'Right box:  Detected circles overlaid in red.', '', ...
                'Note: works best on images with clear circular objects.', ...
                'Ref: Slides example — coin detection'};

        %% RANSAC
        case 'RANSAC Line'
            desc = sprintf('RANSAC Line Fitting: robust line from edge points, dist threshold=%.1f px', param);
            txt = {'RANSAC LINE FITTING  (Fischler & Bolles 1981)', sp(), '', ...
                'RANdom SAmple Consensus:', ...
                '  1. Randomly sample 2 edge points', ...
                '  2. Fit a line through them', ...
                '  3. Count inliers (dist to line < threshold)', ...
                '  4. Repeat 500 iterations; keep best hypothesis', ...
                '  5. Refit line with all best inliers (least squares)', '', ...
                sprintf('Distance threshold: %.1f px', param), ...
                '  Controls how close a point must be to count as inlier.', '', ...
                'Green dots = inlier edge points', ...
                'Red line   = RANSAC best-fit line', ...
                'Middle box = Canny edges used as input points.', '', ...
                'Robust to outliers (unlike least squares).', ...
                'Ref: Fischler & Bolles, CACM 1981'};

        case 'RANSAC Circle'
            desc = sprintf('RANSAC Circle Fitting: robust circle from edge points, dist threshold=%.1f px', param);
            txt = {'RANSAC CIRCLE FITTING  (Fischler & Bolles 1981)', sp(), '', ...
                'RANdom SAmple Consensus (3-point minimal sample):', ...
                '  1. Randomly sample 3 edge points', ...
                '  2. Fit circumscribed circle through them', ...
                '  3. Count inliers (|dist_to_center − r| < threshold)', ...
                '  4. Repeat 500 iterations; keep best hypothesis', '', ...
                sprintf('Distance threshold: %.1f px', param), '', ...
                'Green dots = inlier edge points', ...
                'Red circle = RANSAC best-fit circle', ...
                'Middle box = Canny edges used as input points.', '', ...
                'Note: 3-point circumcircle = minimal sample for circle.', ...
                'Ref: Fischler & Bolles, CACM 1981'};

        %% Stereo Vision
        case 'Epipolar Lines'
            desc = 'Epipolar Lines: fundamental matrix F estimated from matched SURF features between two images';
            txt = {'STEREO VISION — EPIPOLAR GEOMETRY', sp(), '', ...
                'Epipolar constraint: [p2,1]·F·[p1,1]ᵀ = 0', '', ...
                'Pipeline:', ...
                '  1. Detect SURF features in left and right images', ...
                '  2. Match features (ratio test, unique matches)', ...
                '  3. Estimate fundamental matrix F via RANSAC', ...
                '     (estimateFundamentalMatrix)', ...
                '  4. Compute epipolar lines:', ...
                '     epiR = epipolarLine(F,  leftPts)  → lines in right', ...
                '     epiL = epipolarLine(Fᵀ, rightPts) → lines in left', ...
                '  5. Clip lines to image border (lineToBorderPoints)', '', ...
                'Left box:  green dots = matched points, red = epipolar lines', ...
                'Right box: yellow = epipolar lines from left points', '', ...
                'REQUIREMENT: Load right image via "Load Template" button.', '', ...
                'Ref: Hartley & Zisserman; MATLAB epipolarLine()'};

        case 'Structure from Motion'
            desc = 'Structure from Motion: reconstruct 3D point cloud from 2 views via SURF + essential matrix + triangulation';
            txt = {'STRUCTURE FROM MOTION (SfM) — 3D POINT CLOUD', sp(), '', ...
                'Reconstructs the 3D geometry of a scene from 2 images taken from', ...
                'different viewpoints.', '', ...
                'Pipeline:', ...
                '  1. Detect SURF features in left + right images', ...
                '  2. Match features (ratio test, unique matches)', ...
                '  3. Estimate the Essential matrix E (with assumed intrinsics)', ...
                '  4. Recover relative camera pose (R, t) from E', ...
                '  5. Triangulate matched points → 3D world coordinates', ...
                '  6. Plot the 3D point cloud (colored by source image pixel)', '', ...
                'NOTE: camera intrinsics are APPROXIMATED (focal length ≈ image size,', ...
                'principal point at image center). Without true calibration, the 3D', ...
                'cloud is only correct up to a scale + similarity transformation.', '', ...
                'REQUIREMENT: 2 images of the SAME scene from slightly different views.', ...
                'Loaded right image goes through the Load Template button.', '', ...
                'Output: 3D scatter plot with X/Y/Z axes (looks like a wireframe cube', ...
                'around the point cloud).', '', ...
                'Ref: Hartley & Zisserman; MATLAB SfM example'};

        case 'Scanline Matching'
            ws = max(3, 2*floor(param/2)+1);
            desc = sprintf('Scanline Matching: search visualisation, window=%d×%d, auto-picked Harris ref point', ws, ws);
            txt = {'SCANLINE STEREO MATCHING — visualisation', sp(), '', ...
                'Reproduction of the lecture slide "Basic stereo matching algorithm"', ...
                'and "Correspondence search".', '', ...
                'Algorithm:', ...
                '  1. Auto-pick a Harris corner in the LEFT image as reference point', ...
                '  2. Extract reference window (winSz x winSz) around that point', ...
                '  3. Slide candidate windows along the SAME horizontal scanline in RIGHT image', ...
                '  4. Compute SSD between reference and each candidate', ...
                '  5. Best match = candidate with minimum SSD → disparity = refX - bestX', '', ...
                sprintf('Window size: %d x %d px', ws, ws), '', ...
                'Layout:', ...
                '  Left box:  left image + red reference box + purple scanline', ...
                '  Right box: right image + cyan candidate boxes + red best-match box', '', ...
                'REQUIREMENT: stereo pair, scanline assumes rectified images.', '', ...
                'Ref: lecture slides — Basic stereo matching algorithm'};

        case 'Disparity Map'
            ws = max(3, 2*floor(param/2)+1);
            desc = sprintf('Disparity Map: window-based SSD stereo matching, window=%d×%d', ws, ws);
            txt = {'STEREO VISION — DISPARITY MAP', sp(), '', ...
                'Depth from disparity: Z = f·B / (xL − xR)', '', ...
                'Window-based matching (block matching):', ...
                '  For each pixel in left image:', ...
                '    Slide a window along the epipolar scanline in right image', ...
                '    Match by Sum of Squared Differences (SSD)', ...
                '    Best match → disparity d = xL − xR', '', ...
                sprintf('Window size: %d × %d px', ws, ws), ...
                '  Small window → more detail, noisier', ...
                '  Large window → smoother, less detail', '', ...
                'Left box:  left image', ...
                'Middle:    right image', ...
                'Right box: disparity map (brighter = closer)', '', ...
                'Uses MATLAB disparity() when available, else manual SSD.', ...
                'REQUIREMENT: Load right image via "Load Template" button.', '', ...
                'Ref: Basic stereo matching algorithm (lecture slides)'};

        otherwise
            desc=op; txt={op};
    end
end

% [F2] FIX: D0 scaled to image dimensions, not slider max
function K = fPrev(op, D0, nLP, nHP, imgSz)
    sz=64;
    if ~isempty(imgSz) && imgSz(1)>0
        ref=min(imgSz(1),imgSz(2));
    else
        ref=500;
    end
    D0p=max(D0*(sz/ref), 0.5);
    K=buildFreqMask(sz,sz,op,D0p,nLP,nHP);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  UTILITY / FORMATTING FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = kernelResp(img, K)
    if size(img,3)==3
        out=zeros(size(img),'uint8');
        for c=1:3
            ch=imfilter(im2double(img(:,:,c)),K,'replicate');
            out(:,:,c)=im2uint8(mat2gray(ch));
        end
    else
        out=im2uint8(mat2gray(imfilter(im2double(img),K,'replicate')));
    end
end

function g = gray_safe(img)
    if size(img,3)==3, g=rgb2gray(img); else, g=img; end
end

function lines = kText(title_str, K, extra)
    lines={title_str,sp(),'','Kernel values:',''};
    [nr,nc]=size(K);
    for r=1:nr
        row='  [';
        for c=1:nc
            v=K(r,c);
            if v==round(v)&&abs(v)<1e4, row=[row sprintf(' %+5d',v)];    %#ok
            else,                        row=[row sprintf(' %+8.4f',v)];  %#ok
            end
            if c<nc, row=[row '  ']; end  %#ok
        end
        lines=[lines,{[row '  ]']}];  %#ok
    end
    lines=[lines,{''},extra];
end

function lines = fText(title_str, D0, fLines)
    lines={title_str,sp(),'', ...
        sprintf('Cutoff  D0 = %.1f px  (from centre of frequency rectangle)',D0),'', ...
        'Transfer function H(u,v):',''};
    lines=[lines,fLines,{'', ...
        '─────────────────────────────────────────', ...
        'Pipeline: FFT2 → fftshift → H·F → ifftshift → IFFT2 → real', ...
        'Applied per colour channel.  Ref: DIP Ch4 p.14'}];
end

function s = sp()
    s='═══════════════════════════════════════════';
end

function lbl = makeLabel(parent,txt,pos)
    lbl=uilabel(parent,'Text',txt,'Position',pos, ...
        'FontSize',11,'FontColor',[0.75 0.85 1.0],'FontWeight','bold');
end

function lbl = makeAxLabel(parent,txt,pos)
    lbl=uilabel(parent,'Text',txt,'Position',pos,'FontSize',12, ...
        'FontWeight','bold','FontColor',[0.85 0.92 1.0], ...
        'HorizontalAlignment','center','BackgroundColor','none');
end

function styleAxes(ax)
    ax.Color=[0.08 0.08 0.10]; ax.XColor=[0.4 0.4 0.4];
    ax.YColor=[0.4 0.4 0.4]; ax.Box='on';
    ax.XTick=[]; ax.YTick=[];
    ax.DataAspectRatioMode='auto';
    ax.PlotBoxAspectRatioMode='auto';
end

function cmap = divCmap(n)
    h=n/2;
    cmap=[[linspace(0.15,1,h)' linspace(0.25,1,h)' linspace(0.85,1,h)']; ...
          [linspace(1,0.85,h)' linspace(1,0.15,h)' linspace(1,0.15,h)']];
end

function v = ternary(cond,a,b)
    if cond, v=a; else, v=b; end
end
