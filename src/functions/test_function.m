function test_function(handles)

centroids = handles.centroids;
foci = handles.foci;
hologram = handles.hologram;
Npixel = 50;
Nfoci = size(centroids,1);
% reconcuts = zeros(Nfoci,Npixel,Npixel);
[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
CCD_S_DIST = 0.735;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
lambda = 1.0530;
[p,q] = meshgrid(1:Xrange, 1:Yrange);

tempProp=(2*pi/lambda)*(1-((PX_SIZE/CCD_S_DIST)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2);

focusFigure = figure(3);
focusFigure.Units = 'normalized';

for CC=1:size(foci)
    N=round(foci(CC)/lambda);
    prop_l=N*lambda;
    tempPhase=prop_l*tempProp;
    hologram = abs(hologram).*exp(1i*tempPhase);
    recon = fftshift(ifft2(fftshift(hologram)));
    
    centerx = round(centroids(CC,2));
    centery = round(centroids(CC,1));
    reconcut = real(recon(max(1,centerx-Npixel-1):min(1024,centerx+Npixel),max(1,centery-Npixel-1):min(1024,centery+Npixel)));
    fociAxes(CC) = subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC); fociImage(CC) = imagesc(reconcut); axis square; colormap fire; hold on;
    obj_area = find_obj(reconcut);
    title(['object area = ', num2str(obj_area)])
end
