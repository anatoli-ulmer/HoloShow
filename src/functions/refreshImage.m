function refreshImage(hObject, eventdata, handles)
handles.phase = get(handles.phase_slider, 'Value');

handles.hologram.propagated = propagate(abs(handles.hologram.masked), handles.phase);
handles.hologram.propagated = handles.hologram.propagated.*exp(1i*handles.phaseOffset);

if get(handles.decon_checkbox,'value')
    handles.recon = fftshift(ifft2(fftshift(handles.hologram.deconvoluted)));
else
    handles.recon = fftshift(ifft2(fftshift(handles.hologram.propagated)));
end

axes(handles.reconAxes);
handles.reconI.CData = part_and_scale(handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3)),...
                                            handles.logSwitch, handles.partSwitch);                                     
if handles.square
    axis square
else
    axis tight
end
drawnow