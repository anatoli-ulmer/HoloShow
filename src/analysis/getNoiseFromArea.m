function getNoiseFromArea(app)

% Anatoli Ulmer (2021). HoloShow
% (https://github.com/anatoli-ulmer/holoShow)

% Create figure
if ~ishandle(app.handles,'noiseFigure')
    app.handles.noiseFigure = gobjects(1);
end
if ~isgraphics(app.handles.noiseFigure)
    app.handles.noiseFigure = figure('Name', 'Noise Spectrum Figure');
    app.handles.noiseFigure.Tag = 'holoShow.figures.noiseSpectrum';
    app.handles.noiseAxes = axes(app.handles.noiseFigure);
end

imagesc(app.handles.noiseAxes, abs(app.handles.recon));
app.handles.noiseAxes.ColorScale = 'log';
app.handles.noiseAxes.Colormap = 'jet';

app.handles.noiseRectangleangle = round(getrect(gca));
close(gcf);

if app.squareROI_checkbox.Value
    app.handles.noiseRectangle(3) = max([app.handles.noiseRectangle(3),app.handles.noiseRectangle(4)]);
    app.handles.noiseRectangle(4) = max([app.handles.noiseRectangle(3),app.handles.noiseRectangle(4)]);
end

% Get Data from rectangle and normalize it on the number of pixels
app.data.noiseData = app.handles.recon(app.handles.noiseRectangle(2):app.handles.noiseRectangle(2)+app.handles.noiseRectangle(4),app.handles.noiseRectangle(1):app.handles.noiseRectangle(1)+app.handles.noiseRectangle(3));
app.data.noiseData = app.data.noiseData/length(app.data.noiseData);

% Calc 2D FT for Noise
app.data.noiseDataFT = fftshift(fft2(app.data.noiseData,1024,1024));

app.data.noiseRadialAverage = rmean(app.data.noiseDataFT, app.handles.rmean.range, [], app.handles.rmean.bins);

cla(app.handles.noiseAxes);
app.handles.noisePlot = semilogy(app.handles.noiseAxes, 1:512, app.data.noiseRadialAverage); 
app.handles.noiseAxes.Title.String = 'noise';

app.data.noisePowerSpectrum = app.data.noiseRadialAverage.^2;
