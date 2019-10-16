function handles_return = refresh_hologram(hObject, eventdata, handles)
% Needed if parameter values like center of hologram or shift/slit have
% changed to update hologram and mask. Updates data and plots.

if handles.image_correction
    handles = mask_script(handles);
else
    handles.hologram.masked = handles.hologram.orig;
    handles.mask = ones(1024);
    handles.hardmask = ones(1024);
end

handles.hologram.masked = handles.hologram.masked.*exp(1i*handles.phaseOffset);

if ~ishandle(handles.hologramFigure)
    handles.hologramFigure = figure('Name','hologram');
    handles.hologramAxes = axes('parent', handles.hologramFigure);
end

handles.hologramI = imagesc(log10(abs(handles.hologram.masked)), ...
    'parent', handles.hologramAxes,[1, 4.2]);
axis(handles.hologramAxes, 'image'); 
colormap(handles.hologramAxes, imorgen); 
handles.hologramColorbar = colorbar(handles.hologramAxes);
handles.hologramColorbar.Label.String = 'log10(signal) in a.u.';

if ~ishandle(handles.reconstructionFigure)
    handles.reconstructionFigure = figure('Name','reconstruction');
    handles.reconAxes = axes('parent', handles.reconstructionFigure);
end

handles.recon = fftshift(ifft2(fftshift(handles.hologram.masked)));
handles.reconI = imagesc(part_and_scale(...
    handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),...
    handles.rect(1):handles.rect(1)+handles.rect(3)),...
    handles.logSwitch, handles.partSwitch),...
    'parent', handles.reconAxes);
axis(handles.reconAxes, 'image'); set_colormap(handles.colormap, handles.reconAxes);
handles.reconColorbar = colorbar(handles.reconAxes);

if get(handles.scale_checkbox, 'Value')
    caxis(handles.reconAxes, [handles.minScale, handles.maxScale]);
end

handles = refreshImage(hObject, eventdata, handles);
handles_return = handles;
