function handles_return = select_hologram(hObject, eventdata, handles)

% TO DO: CHANGE HARD CODED MASKING

if iscell(handles.filenames)
    handles.currentFile = handles.filenames{handles.fileIndex};
else
    handles.currentFile = handles.filenames;
end

%% READ RAW DATA
fprintf('loading file: %s ...', handles.currentFile);
[~,~,handles.ext] = fileparts(fullfile(handles.pathname,handles.currentFile));

switch handles.ext
    case '.dat'
        handles.hologram.orig = dlmread(fullfile(handles.pathname,handles.currentFile));
    case '.mat'
        load(fullfile(handles.pathname,handles.currentFile));
        handles.hologram.orig = data.hologram;
        if strcmp(handles.currentFile(7:11), 'frame')
            handles.hologram.orig = fliplr(rot90(handles.hologram.orig));
            % HARD CODED MASKING
            handles.hologram.orig(229, 1:513) = 0;
            handles.hologram.orig(230, 1:513) = 0;
            handles.hologram.orig(231, 1:20) = 0;
            handles.hologram.orig(607, 1:21) = 0;
            handles.hologram.orig(1:1024, 1:24) = 0;
            handles.hologram.orig(1:1024, 1000:1024) = 0;
%             handles.hologram.orig(385:511,513:end) = handles.hologram.orig(385:511,513:end)*2;
            handles.hologram.orig = handles.hologram.orig(1:1024,1:1024);
            handles.hologram.orig(512:end,510:end) = simpleshift(handles.hologram.orig(512:end,510:end) , [0,12]);
            handles.hologram.orig(1:511,513:end) = simpleshift(handles.hologram.orig(1:511,513:end) , [0,12]);
            handles.hologram.orig(512:end,:) = simpleshift(handles.hologram.orig(512:end,:) , [13,-1]);
        end
    case '.cxi'
        handles.hologram.orig = h5read(fullfile(handles.pathname, handles.first_file), handles.cxi_entryname, [1 1 handles.fileIndex],[1024 1024 1]);
        try
            handles.hummingbird_mask = h5read(fullfile(handles.pathname, handles.first_file), handles.cxi_maskname);
        catch
            warning('no hummingbird mask found!')
            handles.hummingbird_mask = ones(size(handles.hologram.orig));
        end
    case '.h5'
        handles.hologram.orig = h5read(fullfile(handles.pathname, handles.first_file), handles.cxi_entryname, [1+handles.img_offset 1 handles.fileIndex],[1074 1024 1]);
        content = cellstr(get(handles.config_popupmenu, 'String'));
        experiment = content{get(handles.config_popupmenu, 'Value')};
        if strcmp(experiment, 'FLASH2017')
            handles.refined_mask = dlmread('FLASH2017_refined_mask.dat');
            handles.hologram.orig = detector_offset_correction(handles.hologram.orig, handles.refined_mask, handles.detDistance);
        end
%         handles.hologram.orig = handles.hologram.orig(31:1024+30,1:1024);
%         load('test_int_correction.mat');
%         int_corr(isnan(int_corr))=0;
%         handles.hologram.orig = handles.hologram.orig.*int_corr;
        
%         try
%             handles.hummingbird_mask = h5read(fullfile(handles.pathname, handles.first_file), handles.cxi_maskname, [1+handles.img_offset 1],[1024 1024]);
%         catch
%             warning('no hummingbird mask found!')
%             handles.hummingbird_mask = ones(size(handles.hologram.orig));
%         end
end

fprintf(' done! \n');

%% APPLY IMAGE CORRECTION
if handles.image_correction
    fprintf('applying image correction ...');
    handles = mask_script(handles);
    fprintf(' done! \n');
else
    handles.hologram.masked = handles.hologram.orig;
    handles.mask = ones(1024);
    handles.hardmask =  ones(1024);
end

handles.hologram.masked = handles.hologram.masked.*exp(1i*handles.phaseOffset);

%% CREATE HOLOGRAM FIGURE AND PLOT
if ~ishandle(handles.hologramFigure)
    handles.hologramFigure = figure('Name','hologram');
    handles.hologramAxes = axes('parent', handles.hologramFigure);
end

handles.hologramI = imagesc(log10(abs(handles.hologram.masked)), 'parent', handles.hologramAxes); 
handles.hologramAxes.CLim(1) = 1;
axis(handles.hologramAxes,'image'); colormap(handles.hologramAxes, imorgen); 
handles.hologramColorbar = colorbar(handles.hologramAxes);
handles.hologramColorbar.Label.String = 'log10(signal) in a.u.';

%% CREATE RECONSTRUCTION FIGURE AND PLOT
if ~ishandle(handles.reconstructionFigure)
    handles.reconstructionFigure = figure('Name','reconstruction');
    handles.reconAxes = axes('parent', handles.reconstructionFigure);
end

handles.recon = fftshift(ifft2(fftshift(handles.hologram.masked))); % reconstruction
handles.reconI = imagesc(part_and_scale(handles.recon, handles.logSwitch, handles.partSwitch),...
    'parent', handles.reconAxes); % plot
    axis(handles.reconAxes, 'image'); set_colormap(handles.colormap, handles.reconAxes); 
    handles.reconColorbar = colorbar(handles.reconAxes); 
    if get(handles.scale_checkbox, 'Value')
        caxis(handles.reconAxes, [handles.minScale, handles.maxScale]);
    end

%% SET ROI TO WHOLE IMAGE
handles.rect(1) = 1;
handles.rect(2) = 1;
handles.rect(3) = size(handles.hologram.orig,1)-1;
handles.rect(4) = size(handles.hologram.orig,2)-1;

%% REFRESH PHASE SLIDER

try %#ok<*TRYNC>
    delete(handles.phaseListener);
end
handles.phaseListener = addlistener(handles.phase_slider,'ContinuousValueChange',@(hObject, eventdata) refreshImage(hObject, eventdata, guidata(hObject)));

%% REFRESH PLOT
handles = refreshImage(hObject, eventdata, handles);

%% RETURN HANDLES STRUCTURE
handles_return = handles;
