function handles_return = select_hologram(hObject, eventdata, handles)

if iscell(handles.filenames)
    handles.currentFile = handles.filenames{handles.fileIndex};
else
    handles.currentFile = handles.filenames;
end

%% READ RAW DATA
fprintf('loading file: %s ...', handles.currentFile);
handles.hologram.orig = dlmread(fullfile(handles.pathname,handles.currentFile));
handles.hologram.orig = handles.hologram.orig(1:1024,1:1024);
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
imagesc(log10(abs(handles.hologram.masked)),[1, 4.2]); axis square; colormap fire; colorbar;

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

%% REFRESH PHASE SLIDER AND ARROW KEY LISTENER
try %#ok<*TRYNC>
    delete(handles.phaseListener);
end
try %#ok<*TRYNC>
    delete(handles.arrowKeysListener);
end
handles.phaseListener = addlistener(handles.phase_slider,'ContinuousValueChange',@(hObject, eventdata) refreshImage(hObject, eventdata, handles));
set(handles.reconstructionFigure,'KeyPressFcn',@(hObject, eventdata) arrow_keys_callback(hObject, eventdata, handles));

%% REFRESH PLOT
refreshImage(hObject, eventdata, handles)

%% RETURN HANDLES STRUCTURE
handles_return = handles;
