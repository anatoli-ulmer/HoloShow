function show_recon(app, event)

app.handles.reconI = imagesc(log(abs(app.handles.recon(...
    app.data.recon.roi(2):app.data.recon.roi(2)+app.data.recon.roi(4),...
    app.data.recon.roi(1):app.data.recon.roi(1)+app.data.recon.roi(3)))),...
    'parent', app.handles.reconAxes); 
colormap(app.handles.reconAxes, app.handles.colormap);
app.handles.reconColorbar = colorbar(app.handles.reconAxes);
axis(app.handles.reconAxes, 'image')
if get(app.scale_checkbox, 'Value')
    caxis(app.handles.reconAxes, [app.handles.minScale, app.handles.maxScale]);
end

refreshImage(app, event);
