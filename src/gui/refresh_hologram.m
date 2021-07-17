function refresh_hologram(app, event)

% Needed if parameter values like center of hologram or shift/slit have
% changed to update hologram and mask. Updates data and plots.
% 
% Anatoli Ulmer (2021). HoloShow
% (https://github.com/anatoli-ulmer/holoShow)

if app.applyHologramCorrection_checkbox.Value
    mask_script(app, event);
else
    app.handles.hologram.masked = app.handles.hologram.orig;
    app.handles.mask = ones(1024);
    app.handles.hardmask = ones(1024);
end

app.handles.hologram.masked = app.handles.hologram.masked.*exp(1i*app.handles.phaseOffset);

app.handles.recon = fftshift(ifft2(fftshift(app.handles.hologram.masked)));
app.handles.reconImageData = part_and_scale(...
    app.handles.recon(app.handles.rect(2):app.handles.rect(2)+app.handles.rect(4),...
    app.handles.rect(1):app.handles.rect(1)+app.handles.rect(3)),...
    app.handles.partSwitch);

%% CREATE HOLOGRAM FIGURE AND PLOT
if ~isgraphics(app.handles.hologramFigure)
    app.handles.hologramFigure = figure('Name','hologram');
    app.handles.hologramAxes = axes('parent', app.handles.hologramFigure);
%     app.handles.hologramI = imagesc(log10(abs(app.handles.hologram.masked)), 'parent', app.handles.hologramAxes); 
    app.handles.hologramI = imagesc(app.handles.hologramAxes, app.handles.hologram.masked); 
    axis(app.handles.hologramAxes, 'image');
    app.handles.hologramAxes.ColorScale = 'log';
    % app.handles.hologramAxes.CLim(1) = 1;
    colormap(app.handles.hologramAxes, ihesperia); 
    app.handles.hologramColorbar = colorbar(app.handles.hologramAxes);
    app.handles.hologramColorbar.Label.String = 'signal in a.u.';
else
    app.handles.hologramI.CData = abs(app.handles.hologram.masked);
end



%% CREATE RECONSTRUCTION FIGURE AND PLOT
if ~isgraphics(app.handles.reconstructionFigure)
    app.handles.reconstructionFigure = figure('Name','reconstruction');
    app.handles.reconAxes = axes('parent', app.handles.reconstructionFigure);
    app.handles.reconI = imagesc(app.handles.reconImageData,...
        'parent', app.handles.reconAxes); % plot
    axis(app.handles.reconAxes, 'image'); 
    colormap(app.handles.reconAxes, app.handles.colormap);
    app.handles.reconColorbar = colorbar(app.handles.reconAxes); 
    if get(app.scale_checkbox, 'Value')
        caxis(app.handles.reconAxes, [app.handles.minScale, app.handles.maxScale]);
    end
else
    app.handles.reconI.CData = app.handles.reconImageData;
end

if get(app.scale_checkbox, 'Value')
    caxis(app.handles.reconAxes, [app.handles.minScale, app.handles.maxScale]);
end

refreshImage(app, event);
