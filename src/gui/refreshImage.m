 function refreshImage(app, event)

refreshPhase(app, event)

reconScalebar(app, app.handles.reconAxes)

app.handles.reconColorbar.Label.String = sprintf('%s part in a.u.', app.handles.partSwitch);
app.handles.reconAxes.ColorScale = iif(app.log_checkbox.Value, 'log', 'linear');
