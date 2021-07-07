function select_hologram(app, event)

% TO DO: CHANGE HARD CODED MASKING

% if iscell(app.handles.filenames)
%     app.handles.currentFile = app.handles.filenames{app.handles.fileIndex};
% else
%     app.handles.currentFile = app.handles.filenames;
% end
app.handles.currentFile = app.filenames_listbox.Value;

%% READ RAW DATA
fprintf('loading file: %s ...', app.handles.currentFile);
[~,~,app.handles.ext] = fileparts(fullfile(app.handles.pathname,app.handles.currentFile));

switch app.handles.ext
    case '.dat'
        app.handles.hologram.orig = dlmread(fullfile(app.handles.pathname,app.handles.currentFile));
    case '.mat'
        load(fullfile(app.handles.pathname,app.handles.currentFile), 'data');
        app.handles.hologram.orig = data.hologram;
        if strcmp(app.handles.currentFile(7:11), 'frame')
            app.handles.hologram.orig = fliplr(rot90(app.handles.hologram.orig));
            % HARD CODED MASKING
            app.handles.hologram.orig(229, 1:513) = 0;
            app.handles.hologram.orig(230, 1:513) = 0;
            app.handles.hologram.orig(231, 1:20) = 0;
            app.handles.hologram.orig(607, 1:21) = 0;
            app.handles.hologram.orig(1:1024, 1:24) = 0;
            app.handles.hologram.orig(1:1024, 1000:1024) = 0;
%             app.handles.hologram.orig(385:511,513:end) = app.handles.hologram.orig(385:511,513:end)*2;
            app.handles.hologram.orig = app.handles.hologram.orig(1:1024,1:1024);
            app.handles.hologram.orig(512:end,510:end) = simpleshift(app.handles.hologram.orig(512:end,510:end) , [0,12]);
            app.handles.hologram.orig(1:511,513:end) = simpleshift(app.handles.hologram.orig(1:511,513:end) , [0,12]);
            app.handles.hologram.orig(512:end,:) = simpleshift(app.handles.hologram.orig(512:end,:) , [13,-1]);
        end
    case '.cxi'
        app.handles.hologram.orig = h5read(fullfile(app.handles.pathname, app.handles.first_file), app.handles.cxi_entryname, [1 1 app.handles.fileIndex],[1024 1024 1]);
        try
            app.handles.hummingbird_mask = h5read(fullfile(app.handles.pathname, app.handles.first_file), app.handles.cxi_maskname);
        catch
            warning('no hummingbird mask found!')
            app.handles.hummingbird_mask = ones(size(app.handles.hologram.orig));
        end
    case '.h5'
        app.handles.hologram.orig = h5read(fullfile(app.handles.pathname, app.handles.first_file), app.handles.cxi_entryname, [1+app.handles.img_offset 1 app.handles.fileIndex],[1074 1024 1]);
        content = cellstr(get(app.config_popupmenu, 'String'));
        experiment = content{get(app.config_popupmenu, 'Value')};
        if strcmp(experiment, 'FLASH2017')
            app.handles.refined_mask = dlmread('FLASH2017_refined_mask.dat');
            app.handles.hologram.orig = detector_offset_correction(app.handles.hologram.orig, app.handles.refined_mask, app.handles.detDistance);
        end
%         app.handles.hologram.orig = app.handles.hologram.orig(31:1024+30,1:1024);
%         load('test_int_correction.mat');
%         int_corr(isnan(int_corr))=0;
%         app.handles.hologram.orig = app.handles.hologram.orig.*int_corr;
        
%         try
%             app.handles.hummingbird_mask = h5read(fullfile(app.handles.pathname, app.handles.first_file), app.handles.cxi_maskname, [1+app.handles.img_offset 1],[1024 1024]);
%         catch
%             warning('no hummingbird mask found!')
%             app.handles.hummingbird_mask = ones(size(app.handles.hologram.orig));
%         end
end

fprintf(' done! \n');

%% APPLY IMAGE CORRECTION
if app.handles.image_correction
    fprintf('applying image correction ...');
    mask_script(app, event);
    fprintf(' done! \n');
else
    app.handles.hologram.masked = app.handles.hologram.orig;
    app.handles.mask = ones(1024);
    app.handles.hardmask =  ones(1024);
end

app.handles.hologram.masked = app.handles.hologram.masked.*exp(1i*app.handles.phaseOffset);

%% CREATE HOLOGRAM FIGURE AND PLOT
if ~ishandle(app.handles.hologramFigure)
    app.handles.hologramFigure = figure('Name','hologram');
    app.handles.hologramAxes = axes('parent', app.handles.hologramFigure);
end

app.handles.hologramI = imagesc(log10(abs(app.handles.hologram.masked)), 'parent', app.handles.hologramAxes); 
app.handles.hologramAxes.CLim(1) = 1;
axis(app.handles.hologramAxes,'image'); colormap(app.handles.hologramAxes, imorgen); 
app.handles.hologramColorbar = colorbar(app.handles.hologramAxes);
app.handles.hologramColorbar.Label.String = 'log10(signal) in a.u.';

%% CREATE RECONSTRUCTION FIGURE AND PLOT
if ~ishandle(app.handles.reconstructionFigure)
    app.handles.reconstructionFigure = figure('Name','reconstruction');
    app.handles.reconAxes = axes('parent', app.handles.reconstructionFigure);
end

app.handles.recon = fftshift(ifft2(fftshift(app.handles.hologram.masked))); % reconstruction
app.handles.reconI = imagesc(part_and_scale(app.handles.recon, app.handles.logSwitch, app.handles.partSwitch),...
    'parent', app.handles.reconAxes); % plot
    axis(app.handles.reconAxes, 'image'); set_colormap(app.handles.colormap, app.handles.reconAxes); 
    app.handles.reconColorbar = colorbar(app.handles.reconAxes); 
    if get(app.scale_checkbox, 'Value')
        caxis(app.handles.reconAxes, [app.handles.minScale, app.handles.maxScale]);
    end

%% SET ROI TO WHOLE IMAGE
app.handles.rect(1) = 1;
app.handles.rect(2) = 1;
app.handles.rect(3) = size(app.handles.hologram.orig,1)-1;
app.handles.rect(4) = size(app.handles.hologram.orig,2)-1;

%% REFRESH PHASE SLIDER

try %#ok<*TRYNC>
    delete(app.handles.phaseListener);
end
% app.handles.phaseListener = addlistener(app.handles.phase_slider,'ContinuousValueChange',@(hObject, eventdata) refreshImage(hObject, eventdata, guidata(hObject)));
% app.phase_slider.ValueChangingFcn = @(src, event) refreshImage(app, event);

%% REFRESH PLOT
refreshImage(app, event);

