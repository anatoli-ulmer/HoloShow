function handles_return = refresh_hologram(hObject, eventdata, handles)
% Needed if parameter values like center of hologram or shift/slit have
% changed to update hologram and mask. Updates data and plots.

if handles.image_correction
    handles = mask_script(handles);
else
    handles.hologram.masked = handles.hologram.orig;
    handles.mask = ones(1024);
    handles.hardmask =  ones(1024);
end

handles.hologram.masked = handles.hologram.masked.*exp(1i*handles.phaseOffset);

if ~ishandle(handles.hologramFigure)
    handles.hologramFigure = figure('Name','hologram');
end

figure(handles.hologramFigure);
imagesc(log10(abs(handles.hologram.masked)),[1, 4.2]); axis square; colormap fire; colorbar;

if ~ishandle(handles.reconstructionFigure)
    handles.reconstructionFigure = figure('Name','reconstruction');
end

figure(handles.reconstructionFigure);
handles.recon = fftshift(ifft2(fftshift(handles.hologram.masked)));
handles.reconI = imagesc(part_and_scale(handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3)),...
                                            handles.logSwitch, handles.partSwitch)); axis square; set_colormap(handles.colormap); colorbar;
handles.reconAxes = gca;
if get(handles.scale_checkbox, 'Value')
    axes(handles.reconAxes);
    caxis([handles.minScale, handles.maxScale]);
end

handles = refreshImage(hObject, eventdata, handles);
handles_return = handles;
