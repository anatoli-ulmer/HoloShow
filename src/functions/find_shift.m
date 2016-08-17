function [shift, slit, phaseOffset] = find_shift(hologram,phase,ROI)
% Hier sind zwei Verfahren moeglich. Das implementierte erreicht eine
% Genauigkeit von 1 Pixel. Subpixelgenauigkeit ist in Arbeit.

fprintf('looking for detector shift ...');

[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
CCD_S_DIST = 0.735;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
lambda = 1.0530;
[p,q] = meshgrid(1:Xrange, 1:Yrange);

tempProp=(2*pi/lambda)*(1-((PX_SIZE/CCD_S_DIST)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2);
N=round(phase/lambda);
prop_l=N*lambda;
tempPhase=prop_l*tempProp;

varrange = 4;
delta = 1;
maxMap = 0;

sumrealmap3D = ones(2*varrange/delta+1);
i=1;

for rts = -varrange:delta:varrange
    for cts = -varrange:delta:varrange
        H = abs(hologram);
        Htemp = circshift(abs(hologram), [rts, cts]);
        H(513+rts:1024,:) = Htemp(513+rts:1024,:);
        H = H.*exp(1i*tempPhase);
        
%         figure(40); imagesc(log10(abs(H)),[1,4.2]); axis square; colorbar; colormap fire; drawnow;
        
        recon = fftshift(ifft2(fftshift(H)));
        reconcut = recon(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
        
        tmpalpha = 0;
        tmpvar = 0;
        for alpha = -pi:0.1:pi
            Rcutalpha = reconcut.*exp(1i*alpha);
            newvar = sum(abs(real(Rcutalpha(:))));
            if tmpvar < newvar
                tmpvar = newvar;
                tmpalpha = alpha;
            end
        end
        Rcut = reconcut.*exp(1i*tmpalpha);
        
        ix = round(rts/delta+varrange/delta+1);
        iy = round(cts/delta+varrange/delta+1);
        sumrealmap3D(ix,iy) = sum(abs(real(Rcut(:))));

%         tmpalpha = 1/2*atan(2*sum(real(reconcut(:)).*imag(reconcut(:)))./sum(imag(reconcut(:)).^2-real(reconcut(:)).^2));
%         for j=0:1
%             tmpalpha = tmpalpha + j*pi/2;
%             Rcut = reconcut*exp(1i*tmpalpha);
%             tmpRealSum = sum(abs(real(Rcut(:))).^2);
%             if tmpRealSum > sumrealmap3D(ix,iy)
%                 sumrealmap3D(ix,iy) = tmpRealSum;
%                 maxPhase = tmpalpha;
%             end
%         end
%         
%         if sumrealmap3D(ix,iy) > maxMap
%             maxMap = sumrealmap3D(ix,iy);
%             phaseOffset = maxPhase;
%             shift=cts;
%             slit=rts;
%         end




    end
%     sprintf('%.0f %%\n', 100*i/((2*varrange+1)/delta))
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    statusbar('Looking for detector shift (%.1f%%)...',100*i/((2*varrange+1)/delta));
    i=i+1;
end

statusbar;

figure(11); surf(sumrealmap3D(:,:));
figure(33); imagesc(-varrange:delta:varrange,-varrange:delta:varrange,sumrealmap3D); axis square;

%%
rm = sumrealmap3D/max(sumrealmap3D(:));

[~,ind] = max(rm(:));
[i,j] = ind2sub(size(rm),ind);

koordvec = -varrange:delta:varrange;
slit = koordvec(i);
shift = koordvec(j);

H = abs(hologram);
Htemp = circshift(abs(hologram), [slit, shift]);
H(513:1024,:) = Htemp(513:1024,:);
H = H.*exp(1i*tempPhase);
recon = fftshift(ifft2(fftshift(H)));
reconcut = recon(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));

tmpalpha = 0;
tmpvar = 0;
for alpha = -pi:0.1:pi
    Rcutalpha = reconcut.*exp(1i*alpha);
    newvar = sum(abs(real(Rcutalpha(:))));
    if tmpvar < newvar
        tmpvar = newvar;
        tmpalpha = alpha;
    end
end
phaseOffset = tmpalpha;
Rcut = reconcut.*exp(1i*phaseOffset);

figure(28);
imagesc(real(Rcut)); axis square; colormap gray;

fprintf(' done! \n');