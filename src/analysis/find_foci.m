function foci = find_foci(hologram, centroids, minPhase, maxPhase, steps, pathname, filename, gpuSwitch, showHOLO)
% Copyright (c) 2015, Anatoli Ulmer <anatoli.ulmer@gmail.com>

if nargin<8
    gpuSwitch=false;
end
if nargin<9
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
metric = zeros(length(x),Nfoci);

if gpuSwitch
    hologram = gpuArray(hologram);
    tempProp = gpuArray(tempProp);
    metric = gpuArray(metric);
end

for phase = minPhase:ste:maxPhase
    
    N=round(phase/lambda);
    prop_l=N*lambda;
    tempPhase=prop_l*tempProp;
    
    hologramP = abs(hologram).*exp(1i*tempPhase);
    recon = fftshift(ifft2(fftshift(hologramP)));
    for CC=1:Nfoci
        centerx = round(centroids(CC,2));
        centery = round(centroids(CC,1));
        reconcut = abs(recon(max(1,centerx-Npixel-1):min(1024,centerx+Npixel),max(1,centery-Npixel-1):min(1024,centery+Npixel)));
 
        %%%%% VARICANCE AUTOFOCUS %%%%%
        metric(i,CC) = var(reconcut(:));
        
        if showHOLO
            if firstS(CC)
                fociAxes(CC) = subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC); fociImage(CC) = imagesc(abs(reconcut)); axis square; colormap fire; hold on;
                firstS(CC) = false;
            else
                %                 subplot(Nfoci,1,CC);
                set(fociImage(CC), 'CData', abs(gather(reconcut)));
            end
            drawnow;
        end
    end
    i=i+1;
end

if gpuSwitch
    focusedCuts = gpuArray(zeros(size(reconcut,1), size(reconcut,2), Nfoci));
else
    focusedCuts = zeros(size(reconcut,1), size(reconcut,2), Nfoci);
end

index=true(1,1,Nfoci);
nbrPixels=zeros(1,Nfoci);
I=gpuArray(zeros(1,Nfoci));

for CC=1:Nfoci
    [~,I(CC)] = max(metric(:,CC));
    foci(CC) = x(I(CC)); %#ok<AGROW>
    N=round(x(I(CC))/lambda);
    prop_l=N*lambda;
    tempPhase=prop_l*tempProp;
    
    hologram = abs(hologram).*exp(1i*tempPhase);
    recon = fftshift(ifft2(fftshift(hologram)));
    
    centerx = round(centroids(CC,2));
    centery = round(centroids(CC,1));
    reconcut = real(recon(max(1,centerx-Npixel-1):min(1024,centerx+Npixel),max(1,centery-Npixel-1):min(1024,centery+Npixel)));
    
    nbrPixels(CC) = size_CC(abs(gather(reconcut)));
    
    if nbrPixels(CC)>1000
        focusedCuts(1:size(reconcut,1),1:size(reconcut,2),CC) = reconcut;
    else
        index(CC)=false;
    end
end

focusedCuts=focusedCuts(:,:,index);
nbrPixels=nbrPixels(index(1,1,:));
I=I(index(1,1,:));
focusedCuts=gather(focusedCuts);

Nfoci=sum(index);

if Nfoci>0
    figure(34555)
    for CC=1:Nfoci
        subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC); imagesc(real(focusedCuts(:,:,CC))); axis square; 
        title(['focus at ', num2str(round(x(I(CC)))), ', size ', num2str(nbrPixels(CC))]);
        colormap gray;
    end
    
    if ~exist(pathname(end-5:end),'dir')
        mkdir(pathname(end-5:end))
    end

    print(gcf,fullfile(pathname(end-5:end),[filename(1:end-3),'png']),'-dpng')
end