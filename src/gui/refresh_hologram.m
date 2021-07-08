function refresh_hologram(app, event)
% Needed if parameter values like center of hologram or shift/slit have
% changed to update hologram and mask. Updates data and plots.


if app.handles.image_correction
    mask_script(app, event);
else
    app.handles.hologram.masked = app.handles.hologram.orig;
    app.handles.mask = ones(1024);
    app.handles.hardmask = ones(1024);
end

app.handles.hologram.masked = app.handles.hologram.masked.*exp(1i*app.handles.phaseOffset);

if ~ishandle(app.handles.hologramFigure)
    app.handles.hologramFigure = figure('Name','hologram');
    app.handles.hologramAxes = axes('parent', app.handles.hologramFigure);
end

app.handles.hologramI = imagesc(log10(abs(app.handles.hologram.masked)), ...
    'parent', app.handles.hologramAxes,[1, 4.2]);
axis(app.handles.hologramAxes, 'image'); 
colormap(app.handles.hologramAxes, imorgen); 
app.handles.hologramColorbar = colorbar(app.handles.hologramAxes);
app.handles.hologramColorbar.Label.String = 'log10(signal) in a.u.';

if ~ishandle(app.handles.reconstructionFigure)
    app.handles.reconstructionFigure = figure('Name','reconstruction');
    app.handles.reconAxes = axes('parent', app.handles.reconstructionFigure);
end

app.handles.recon = fftshift(ifft2(fftshift(app.handles.hologram.masked)));
app.handles.reconI = imagesc(part_and_scale(...
    app.handles.recon(app.handles.rect(2):app.handles.rect(2)+app.handles.rect(4),...
    app.handles.rect(1):app.handles.rect(1)+app.handles.rect(3)),...
    app.handles.logSwitch, app.handles.partSwitch),...
    'parent', app.handles.reconAxes);
axis(app.handles.reconAxes, 'image'); set_colormap(app.handles.colormap, app.handles.reconAxes);
app.handles.reconColorbar = colorbar(app.handles.reconAxes);

if get(app.scale_checkbox, 'Value')
    caxis(app.handles.reconAxes, [app.handles.minScale, app.handles.maxScale]);
end

refreshImage(app, event);
