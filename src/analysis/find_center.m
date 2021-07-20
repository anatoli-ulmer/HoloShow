function [xshift, yshift, phaseOffset] = find_center(handles)
% Hier sind zwei Verfahren moeglich. Das implementierte erreicht eine
% Genauigkeit von 1 Pixel. Subpixelgenauigkeit ist in Arbeit.

hologram = handles.hologram.masked;
phase = handles.phase*1e-9;
ROI = handles.rect;
lambda = handles.lambda;
CCD_S_DIST = handles.detDistance;

fprintf('looking for center of hologram ...\n');
[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
[p,q] = meshgrid(1:Xrange, 1:Yrange);

tempProp=(2*pi/lambda)*(1-((PX_SIZE/CCD_S_DIST)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2);
N=round(phase/lambda);
prop_l=N*lambda;
tempPhase=prop_l*tempProp;

varrange = 10;
delta = 1;
maxMap = 0;

sumrealmap3D = ones(2*varrange/delta+1);
[phx,phy] = meshgrid(1:1+ROI(4),1:1+ROI(3));
phx = phx/Xrange*2*pi;
phy = phy/Yrange*2*pi;

H=abs(hologram);
H = H.*exp(1i*tempPhase);
recon = fftshift(ifft2(fftshift(H)));
reconcutOld = recon(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));

i=1;
maxPhase = 0;
for rts = -varrange:delta:varrange
    for cts = -varrange:delta:varrange
        
        ix = round(rts/delta+varrange/delta+1);
        iy = round(cts/delta+varrange/delta+1);
        
        reconcut = reconcutOld.*exp(1i*(cts*phx+rts*phy));
        
        % here the magic happens: (analytical solution)
        tmpalpha = 1/2*atan(2*sum(real(reconcut(:)).*imag(reconcut(:)))./sum(imag(reconcut(:)).^2-real(reconcut(:)).^2));
        for j=0:1
            tmpalpha = tmpalpha + j*pi/2;
            Rcut = reconcut*exp(1i*tmpalpha);
            tmpRealSum = sum(abs(real(Rcut(:))).^2);
            if tmpRealSum > sumrealmap3D(ix,iy)
                sumrealmap3D(ix,iy) = tmpRealSum;
                maxPhase = tmpalpha;
            end
        end
        
        if sumrealmap3D(ix,iy) > maxMap
            maxMap = sumrealmap3D(ix,iy);
            phaseOffset = maxPhase;
            xshift=cts;
            yshift=rts;
        end
    end
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    statusbar('Looking for center (%.1f%%)...',100*i/((2*varrange+1)/delta));
    i=i+1;
end

statusbar;

% figure(11); surf(sumrealmap3D(:,:));
figure(33); imagesc(-varrange:delta:varrange,-varrange:delta:varrange,sumrealmap3D); axis image;
colormap gray; colorbar; title('finding center position metric'); drawnow
xlabel('shift in x')
ylabel('shift in y')

fprintf(' done! \n');
