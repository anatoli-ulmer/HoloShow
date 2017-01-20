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
end
figure(handles.hologramFigure);
imagesc(log10(abs(handles.hologram.masked)),[0, 4.2]); axis square; colormap morgenstemning; colorbar;

%% CREATE RECONSTRUCTION FIGURE AND PLOT
if ~ishandle(handles.reconstructionFigure)
    handles.reconstructionFigure = figure('Name','reconstruction');
end
figure(handles.reconstructionFigure);

handles.recon = fftshift(ifft2(fftshift(handles.hologram.masked))); % reconstruction
handles.reconI = imagesc(part_and_scale(handles.recon, handles.logSwitch, handles.partSwitch)); % plot
    axis square; set_colormap(handles.colormap); colorbar; 
    handles.reconAxes = gca;
    if get(handles.scale_checkbox, 'Value')
        axes(handles.reconAxes);
        caxis([handles.minScale, handles.maxScale]);
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
