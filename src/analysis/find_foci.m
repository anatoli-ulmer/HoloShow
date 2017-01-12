function foci = find_foci(hologram, lambda, det_distance, minPhase, maxPhase, centroids, steps, gpuSwitch, showHOLO)
% Copyright (c) 2015, Anatoli Ulmer <anatoli.ulmer@gmail.com>

if nargin<8
    gpuSwitch=false;
end
if nargin<9
    showHOLO = false;
end

Nfoci = size(centroids,1);
Npixel = 50;
[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
[p,q] = meshgrid(1:Xrange, 1:Yrange);

tempProp=(2*pi/(lambda*1e9))*(1-((PX_SIZE/det_distance)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2); % plane wave propagation
ste = (maxPhase-minPhase)/steps;
% ste = lambda/(2*atan(256*PX_SIZE/det_distance)^2)*1e9; % FROM DOF (~half detector illuminated)

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
    
    tempPhase=phase*tempProp;
    hologram = abs(hologram).*exp(1i*tempPhase);
    recon = ift2(hologram);

    for CC=1:Nfoci
        centerx = round(centroids(CC,2));
        centery = round(centroids(CC,1));
        reconcut = recon(max(1,centerx-Npixel-1):min(1024,centerx+Npixel),max(1,centery-Npixel-1):min(1024,centery+Npixel));
 
        %%%%% VARICANCE AUTOFOCUS %%%%%
        ma = abs(mean(reconcut(:)));
        metric(i,CC) = var(abs(reconcut(:))-ma);
        
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

figure(3332);
plot(metric)

for CC=1:Nfoci
    while true
    [~,I] = max(metric(:,CC));
    switch x(I)
        case x(1)
            metric(1,CC) = 0;
        case x(end)
            metric(end,CC) = 0;
        otherwise
            break
    end
    end
    
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
    colormap gray;
    
    nbrPixels(CC) = size_CC(abs(gather(reconcut)));
    
    if nbrPixels(CC)>500
        focusedCuts(1:size(reconcut,1),1:size(reconcut,2),CC) = reconcut;
    else
        index(CC)=false;
    end
end


figure(3333);
plot(metric)

focusedCuts=focusedCuts(:,:,index);
nbrPixels=nbrPixels(index(1,1,:));
I=I(index(1,1,:));
focusedCuts=gather(focusedCuts);

Nfoci=sum(index);

if Nfoci>0
    figure(34555)
    for CC=1:Nfoci
        subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC); imagesc(real(focusedCuts(:,:,CC))); axis square; 
        try
            title(['focus at ', num2str(round(x(I(CC)))), ', size ', num2str(nbrPixels(CC))]);
        catch
        end
        colormap gray;
    end
end