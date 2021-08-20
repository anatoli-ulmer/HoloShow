function refreshPhase(app, event)

% app.handles.phase = app.phase_slider.Value;
% app.phase_edit.Value = num2str(round(app.handles.phase));
% set(app.handles.phase_edit, 'String', num2str(round(app.handles.phase)));

if app.decon_checkbox.Value
    app.handles.hologram.propagated = propagateHologram(app.handles.hologram.deconvoluted, ...
        app.handles.phase, app.handles.lambda, app.handles.detDistance, app.handles.cut_center);
else
    app.handles.hologram.propagated = propagateHologram(abs(app.handles.hologram.masked), ...
        app.handles.phase, app.handles.lambda, app.handles.detDistance, app.handles.cut_center);
end
% app.handles.hologram.propagated = app.handles.hologram.propagated.*...
% exp(1i*app.handles.phaseOffset);

app.handles.recon = ift2(app.handles.hologram.propagated);

app.handles.reconI.CData = part_and_scale(app.handles.recon(...
    app.data.recon.roi(2):app.data.recon.roi(2)+app.data.recon.roi(4),app.data.recon.roi(1):app.data.recon.roi(1)+app.data.recon.roi(3)),...
    app.handles.partSwitch);
app.handles.reconAxes.XLim = [1, 1+app.data.recon.roi(3)];
app.handles.reconAxes.YLim = [1, 1+app.data.recon.roi(4)];
grid(app.handles.reconAxes, false);
% app.handles.reconAxes.XLim = [app.data.recon.roi(1), app.data.recon.roi(1)+app.data.recon.roi(3)];
% app.handles.reconAxes.YLim = [app.data.recon.roi(2), app.data.recon.roi(2)+app.data.recon.roi(4)];

drawnow
