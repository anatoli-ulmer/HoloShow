function show_recon(app, event)

app.handles.reconI = imagesc(log(abs(app.handles.recon(...
    app.handles.rect(2):app.handles.rect(2)+app.handles.rect(4),...
    app.handles.rect(1):app.handles.rect(1)+app.handles.rect(3)))),...
    'parent', app.handles.reconAxes); 
set_colormap(app.handles.colormap, app.handles.reconAxes);
app.handles.reconColorbar = colorbar(app.handles.reconAxes);
axis(app.handles.reconAxes, 'image')
if get(app.scale_checkbox, 'Value')
    caxis(app.handles.reconAxes, [app.handles.minScale, app.handles.maxScale]);
end

refreshImage(app, app.handles.reconAxes);
