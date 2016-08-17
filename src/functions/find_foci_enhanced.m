function foci = find_foci(hologram, centroids, minPhase, maxPhase, steps, showHOLO, filename, phaseMatrix)
% Copyright (c) 2015, Anatoli Ulmer <anatoli.ulmer@gmail.com>

if nargin<6
    showHOLO = false;
end

Nfoci = size(centroids,1);
Npixel = 50;
reconcuts = zeros(Nfoci,Npixel,Npixel);
[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
CCD_S_DIST = 0.735;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
lambda = 1.0530;
[p,q] = meshgrid(1:Xrange, 1:Yrange);

tempProp=(2*pi/lambda)*(1-((PX_SIZE/CCD_S_DIST)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2);
ste = (maxPhase-minPhase)/steps;

i=1;

firstS = true(Nfoci);
x = minPhase:ste:maxPhase;
variance = zeros(length(x),Nfoci);

try %#ok<TRYNC>
    close(3)
end
focusFigure = figure(3);
focusFigure.Units = 'normalized';
% set(focusFigure,'Name','find focus','Position', [0.1,0.3,0.5,0.2]);

for phase = minPhase:ste:maxPhase
    
%     N=round(phase/lambda);
%     prop_l=N*lambda;
%     tempPhase=prop_l*tempProp;
    
%     hologram = abs(hologram).*exp(1i*tempPhase);
    hologram = abs(hologram).*phaseMatrix.data(:,:,i);
    recon = fftshift(ifft2(fftshift(hologram)));
    for CC=1:Nfoci
        centerx = round(centroids(CC,2));
        centery = round(centroids(CC,1));
        reconcut = abs(recon(max(1,centerx-Npixel-1):min(1024,centerx+Npixel),max(1,centery-Npixel-1):min(1024,centery+Npixel)));
        variance(i,CC) = var(reconcut(:));
        
        if showHOLO
            if firstS(CC)
                fociAxes(CC) = subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC); fociImage(CC) = imagesc(abs(reconcut)); axis square; colormap fire; hold on;
                firstS(CC) = false;
            else
                %                 subplot(Nfoci,1,CC);
                set(fociImage(CC), 'CData', abs(reconcut));
            end
            drawnow;
        end
    end
    i=i+1;
end

for CC=1:Nfoci
    [M,I] = max(variance(:,CC));
    foci(CC) = x(I);
    N=round(x(I)/lambda);
    prop_l=N*lambda;
    tempPhase=prop_l*tempProp;
    
    hologram = abs(hologram).*exp(1i*tempPhase);
    recon = fftshift(ifft2(fftshift(hologram)));
    
    centerx = round(centroids(CC,2));
    centery = round(centroids(CC,1));
    reconcut = real(recon(max(1,centerx-Npixel-1):min(1024,centerx+Npixel),max(1,centery-Npixel-1):min(1024,centery+Npixel)));
    
    if ~showHOLO
        fociAxes(CC) = subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC); fociImage(CC) = imagesc(abs(reconcut)); axis square; colormap fire; hold on;
    end
    
    set(fociImage(CC), 'CData', reconcut);
    axes(fociAxes(CC));
    title(['focus at ', num2str(round(x(I)))]);
    colormap gray;
end

if ~exist('test2','dir')
    mkdir('test2')
end
print(gcf,fullfile('test2',[filename(1:end-3),'png']),'-dpng')
