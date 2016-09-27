function [noiseSpec, noiseSpec2D] = get_noise_spectrum(handles)
figure;
imagesc(log10(abs(handles.recon))); 
colormap jet; axis square;
handles.noiseRect = getrect(gca);
close(gcf);
handles.noiseRect = round(handles.noiseRect);
handles.square = get(handles.square_checkbox, 'Value');
if handles.square
    handles.noiseRect(3) = max([handles.noiseRect(3),handles.noiseRect(4)]);
    handles.noiseRect(4) = max([handles.noiseRect(3),handles.noiseRect(4)]);
end
noise = handles.recon(handles.noiseRect(2):handles.noiseRect(2)+handles.noiseRect(4),handles.noiseRect(1):handles.noiseRect(1)+handles.noiseRect(3));
noise = noise/length(noise);
noiseSpec2D = fftshift(abs(fft2(noise,1024,1024)));
temp = rscan(noiseSpec2D,'dispflag',false);
temp = temp(1:511);
figure(80); plot(1:511,log(temp(1:511))); title('noise');
noiseSpec = temp.^2;