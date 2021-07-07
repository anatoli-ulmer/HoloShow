function [noiseSpec, noiseSpec2D] = get_noise_spectrum(app)
figure;
imagesc(log10(abs(app.handles.recon))); 
colormap jet; axis square;
app.handles.noiseRect = getrect(gca);
close(gcf);
app.handles.noiseRect = round(app.handles.noiseRect);
app.handles.square = get(app.square_checkbox, 'Value');
if app.handles.square
    app.handles.noiseRect(3) = max([app.handles.noiseRect(3),app.handles.noiseRect(4)]);
    app.handles.noiseRect(4) = max([app.handles.noiseRect(3),app.handles.noiseRect(4)]);
end
noise = app.handles.recon(app.handles.noiseRect(2):app.handles.noiseRect(2)+app.handles.noiseRect(4),app.handles.noiseRect(1):app.handles.noiseRect(1)+app.handles.noiseRect(3));
noise = noise/length(noise);
noiseSpec2D = fftshift(abs(fft2(noise,1024,1024)));
temp = rscan(noiseSpec2D,'dispflag',false);
temp = temp(1:511);
figure(80); plot(1:511,log(temp(1:511))); title('noise');
noiseSpec = temp.^2;
