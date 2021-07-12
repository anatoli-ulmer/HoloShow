 function refreshImage(app, event)

% app.handles.phase = app.phase_slider.Value;
% app.phase_edit.Value = num2str(round(app.handles.phase));
% set(app.handles.phase_edit, 'String', num2str(round(app.handles.phase)));

% if app.decon_checkbox.Value
%     app.handles.hologram.propagated = propagate(app.handles.hologram.deconvoluted, app.handles.phase, app.handles.lambda, app.handles.detDistance, app.handles.cut_center);
% else
%     app.handles.hologram.propagated = propagate(abs(app.handles.hologram.masked), app.handles.phase, app.handles.lambda, app.handles.detDistance, app.handles.cut_center);
% end
% %     app.handles.hologram.propagated = app.handles.hologram.propagated.*exp(1i*app.handles.phaseOffset);
% app.handles.recon = ift2(app.handles.hologram.propagated);
% 
% app.handles.reconI.CData = part_and_scale(app.handles.recon(app.handles.rect(2):app.handles.rect(2)+app.handles.rect(4),app.handles.rect(1):app.handles.rect(1)+app.handles.rect(3)),...
%                                            app.handles.partSwitch);

refreshPhase(app, event)

reconScalebar(app, app.handles.reconAxes)

app.handles.reconColorbar.Label.String = sprintf('%s part in a.u.', app.handles.partSwitch);

if app.log_checkbox.Value
%     output = log10(abs(output));
    app.handles.reconAxes.ColorScale = 'log';
else
    app.handles.reconAxes.ColorScale = 'linear';
end

drawnow
