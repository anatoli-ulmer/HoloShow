function handles_return = refreshImage(~, ~, handles)

handles.phase = get(handles.phase_slider, 'Value');
set(handles.phase_edit, 'String', num2str(round(handles.phase)));

if get(handles.decon_checkbox,'value')
    handles.recon = ift2(handles.hologram.deconvoluted);
else
    handles.hologram.propagated = propagate(abs(handles.hologram.masked), handles.phase, handles.lambda, handles.detDistance);
    handles.hologram.propagated = handles.hologram.propagated.*exp(1i*handles.phaseOffset);
    handles.recon = ift2(handles.hologram.propagated);
end

figure(handles.reconstructionFigure);
handles.reconI.CData = part_and_scale(handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3)),...
                                            handles.logSwitch, handles.partSwitch);

dx = handles.lambda/2/sin(atan(512*75e-6/handles.detDistance))*1e9;
scalebar(handles.reconAxes, dx);


if handles.square 
    axis square
else
    axis tight
end
drawnow

handles_return = handles;