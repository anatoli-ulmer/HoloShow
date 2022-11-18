function mask_script(app, event)
% Performs:
%     - common mode correction
%     - shifting of scattering pattern and mask

%% PARAMETERS

HP_filter = app.handles.HPfiltering;
HP_radius = app.handles.HPfrequency;
LP_filter = app.handles.LPfiltering;
LP_radius = app.handles.LPfrequency;
IF_filter = app.handles.IF_filtering;
IF_value = app.handles.IF_value;
CM_thresh = app.handles.cm_thresh;

% app.handles.photon_adu = 95;
% app.handles.adu_min = -0.5;
% photon_adu = app.handles.photon_adu;
% app.handles.adu_min = 0;
% app.handles.adu_max = 11000;
rowsToshift = round(app.handles.ycenter);
columnsToShift = round(app.handles.xcenter);
slit = app.handles.add_slit;
shift = app.handles.add_shift;

SMOOTH_FACTOR = 3; % smooth parameter for mask % ORIGINAL = 5 !!!
GAUSS_CUTOFF = 0.98; % ORIGINAL = 0.99

DO_SMOOTHING = app.handles.smoothMask;

% Switches for what to show
showMASKS = 0; % show used mask
showCM = 0; % show common mode correction
showSMOOTH = false; % show smoothed mask and pattern

%% LOAD DATA & MASK

origdata = app.handles.hologram.orig;
origdata_photons = origdata ./ app.handles.photon_adu;
% try
%     origdata = origdata  .* (~app.handles.hummingbird_mask);
% catch
% %     warning('could not apply hummingbird mask')
%     fprintf('No applicable hummingbird mask.\n')
% end
slit = 0;
app.masking.gap_orig = ones(size(app.handles.hologram.orig));

% app.masking.gap_orig(482:539, :) = 0;
% app.masking.center_orig = double( ...
%     ~(disc(31, [-22 + slit / 2, 0], size(app.handles.hologram.orig)) ...
%     | disc(31, [29 - slit / 2, 4], size(app.handles.hologram.orig))));


if app.handles.load_mask
    mask = app.handles.origmask;
else
    mask = ones(size(origdata));
end

hCenter = size(origdata) / 2 + 1;

app.masking.gap = app.masking.gap_orig( ...
    hCenter(1)-512:hCenter(1)+511, hCenter(2)-512:hCenter(2)+511);
% app.masking.center = app.masking.center_orig( ...
%     hCenter(1)-512:hCenter(1)+511, hCenter(2)-512:hCenter(2)+511);
app.masking.broken = ones(size(app.handles.hologram.orig));
% app.masking.broken(790:849, 447:495) = 0;
% app.masking.broken(907:929, 517:607) = 0;

gapcentermask = double(app.masking.gap & app.masking.center & app.masking.broken);

mask(~gapcentermask) = 0;
mask = double(mask);
% size(origdata)
% mask(isnan(origdata))=0;

% figure(9000); imagesc(app.handles.origmask)
if showMASKS
    figure(113345) %#ok<*UNRCH>
    set(gcf, 'Name', 'showMASKS');
    subplot(131);
    imagesc(app.handles.origmask);
    axis image;
    subplot(132);
    imagesc(mask);
    axis image;
    subplot(133);
    imagesc(origdata);
    axis image;
    set(gca, 'ColorScale', 'log');
end

if ~isfield(app.handles, 'hummingbird_mask')
    app.handles.hummingbird_mask = ones(size(app.handles.origmask));
end

% figure(3343); imagesc(app.handles.hummingbird_mask>0);

%% CENTER PICTURE & COMMON MODE

% CORRECTION OF CENTER SHIFT
data = simpleshift(origdata, [rowsToshift, columnsToShift]);
mask = simpleshift(mask, [rowsToshift, columnsToShift]);
gapcentermask = simpleshift(gapcentermask, [rowsToshift, columnsToShift]);
[rowsToshift, columnsToShift]

% figure(3343); subplot(121); imagesc(mask); axis image;
% subplot(122); imagesc(data); axis image;

% slit
% shift
% rowsToshift
% columnsToShift
% SECOND CORRECTION THROUH VARIANCE AND DETECTOR SHIFTS
dataShifted = simpleshift(data, [slit, shift]);
maskShifted = simpleshift(mask, [slit, shift]);
gapcentermaskShifted = simpleshift(gapcentermask, [slit, shift]);
data(513+slit:end, :) = dataShifted(513+slit:end, :);
mask(513+slit:end, :) = maskShifted(513+slit:end, :);
gapcentermask(513+slit:end, :) = gapcentermaskShifted(513+slit:end, :);
mask(513:513+slit, :) = 0;
gapcentermask(513:513+slit, :) = 0;


gapcentermask(abs(data) >= app.handles.adu_max) = 0;
data(abs(data) >= app.handles.adu_max) = nan; % set saturated pixels to nan

if IF_filter
    data(abs(data) > IF_value) = nan;
end
% data(data<-app.handles.photon_adu)=nan;
% app.handles.photon_adu
mask(isnan(data)) = 0;
data(isnan(data)) = 0;


% HIGHPASS FILTERING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Modified see below!
if HP_filter
    [X, Y] = meshgrid(-512:511, -512:511);
    lowp = X.^2 + Y.^2 < HP_radius^2;
    mask(lowp) = 0;
    gapcentermask(lowp) = 0;
end

% LOWPASS FILTERING
if LP_filter
    [X, Y] = meshgrid(-512:511, -512:511);
    highp = X.^2 + Y.^2 > LP_radius^2;
    mask(highp) = 0;
    gapcentermask(highp) = 0;
end

data = data / app.handles.photon_adu;

if showCM
    app.handles.histogram.figure = figure(992228); clf
    app.handles.histogram.axes = axes(app.handles.histogram.figure);
    histogram(app.handles.histogram.axes, data(data < 2 & data > -1), ...
        'FaceAlpha', .3, EdgeAlpha = .2, DisplayName = 'before cm');
    app.handles.histogram.axes.NextPlot = 'add';
end


% COMMON MODE CORRECTION
if app.handles.do_cm
    data = common_mode_correction(data, -CM_thresh, CM_thresh, 1);
    data = common_mode_correction(data, -CM_thresh, CM_thresh, 2);
end

if showCM
    histogram(app.handles.histogram.axes, data(data < 2 & data > -1), ...
        'FaceAlpha', .3, EdgeAlpha = .5, DisplayName = 'after cm');
    app.handles.histogram.axes.YScale = 'log';
    legend(app.handles.histogram.axes);
    grid(app.handles.histogram.axes, "on");
    app.handles.histogram.axes.Legend.Title.String = 'Common Mode Correction';
    %     app.handles.hologram.axes.ColorScale = 'linear';
    %     app.handles.hologram.axes.CLim = [-100,100];
end

if ~isnan(app.handles.photon_adu)
    data = gain_correction(data, 1);
end

if showCM
%     figure(333488); clf
%     hax2 = axes;
    histogram(app.handles.histogram.axes, data(data<2 & data > -1), ...
        'FaceAlpha', .3, EdgeAlpha = .2, DisplayName='after gain');
%     app.handles.histogram.axes.YScale = 'log';
end


if showCM
    cmFig = figure(22);
    clf;
    set(cmFig, 'Name', 'showCM');
    cmTL = tiledlayout(cmFig, 'flow');

    cmAx(1) = nexttile(cmTL);
    imagesc(cmAx(1), origdata_photons);
    colormap(hesperia);
    axis(cmAx(1), 'image');
%     cmAx(1).ColorScale = 'log';
%     cmAx(1).CLim(1) = 0.1;
    cmAx(1).CLim = [-1, 1];

    %     cmAx(2) = nexttile(cmTL);
    %     imagesc(cmAx(2), mask);
    %     axis(cmAx(2), 'image');
    %     cmAx(2).ColorScale = 'log';
    %     cmAx(3).CLim(1) = 0.1;
    %     subplot(222);
    %     imagesc(mask);
    %     axis image;

    cmAx(3) = nexttile(cmTL);
    imagesc(cmAx(3), data);
    axis(cmAx(3), 'image');
%     cmAx(3).ColorScale = 'log';
    cmAx(3).CLim = [-1, 1];
end

% data(data < app.handles.adu_min / app.handles.photon_adu) = 0;

data = data / app.handles.gain;
if isfield(app.handles, 'photon_min')
    %     data(data<app.handles.photon_min) = 0;
end

%% SMOOTH MASK

if DO_SMOOTHING
    blurred = imgaussfilt(mask, SMOOTH_FACTOR);
    %     blurred=imgaussfilt(gapcentermask,SMOOTH_FACTOR);
    %     figure(2223322); imagesc(mask);

    newMask = 1 - (blurred < GAUSS_CUTOFF);
    newMask = imgaussfilt(newMask, SMOOTH_FACTOR);
else
    newMask = mask;
end

newMask(~mask) = 0;
newMask(~gapcentermask) = 0;

if showSMOOTH
    figure(35234);
    clf;
    set(gcf, 'Name', 'showSMOOTH');
    subplot(121);
    imagesc(newMask);
    axis square;
    colormap gray;
    colorbar;
    subplot(122);
    imagesc(log(abs(newMask)), [0, 8]);
    axis square;
    colormap fire;
    colorbar;
end

app.handles.mask = newMask;
app.handles.hardmask = mask;
app.handles.hologram.corrected = data;
app.handles.hologram.masked = data .* newMask;

end