function handles_return = refreshImage(hObject, eventdata, handles)

handles.phase = get(handles.phase_slider, 'Value');
set(handles.phase_edit, 'String', num2str(round(handles.phase)));

if get(handles.decon_checkbox,'value')
    handles.recon = ift2(handles.hologram.deconvoluted);
else
    handles.hologram.propagated = propagate(abs(handles.hologram.masked), handles.phase, handles.lambda, handles.detDistance);
    handles.hologram.propagated = handles.hologram.propagated.*exp(1i*handles.phaseOffset);
    handles.recon = ift2(handles.hologram.propagated);
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

handles_return = handles;