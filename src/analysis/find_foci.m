function foci = find_foci(hologram, lambda, det_distance, centroids, varargin)
% Copyright (c) 2015, Anatoli Ulmer <anatoli.ulmer@gmail.com>

if size(centroids,1)==0
    foci = 0;
    return
end

z_start = -50000;
z_end = 50000;
steps = 20;
use_gpu = false;
show_results = false;
crop_factor = 1;

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'z_start', z_start = varargin{ni+1};
            case 'z_end', z_end = varargin{ni+1};
            case 'steps', steps = varargin{ni+1};
            case 'use_gpu', use_gpu = varargin{ni+1};
            case 'show_results', show_results = varargin{ni+1};
            case 'crop_factor', crop_factor = varargin{ni+1};
        end
    end
end

if crop_factor > 1
    hologram = crop_image(hologram, crop_factor);
    centroids = round(centroids/crop_factor);
    sprintf('cropped by %s', crop_factor);
end

Nfoci = size(centroids,1);
Npixel = round(80/crop_factor);
[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
[p,q] = meshgrid(1:Xrange, 1:Yrange);

tempProp=(2*pi/(lambda*1e9))*(1-((PX_SIZE/det_distance)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2); % plane wave propagation
ste = (z_end-z_start)/steps;
% ste = lambda/(2*atan(256*PX_SIZE/det_distance)^2)*1e9; % FROM DOF (~half detector illuminated)

i=1;

firstS = true(Nfoci);
x = z_start:ste:z_end;
metric = zeros(length(x),Nfoci);

if use_gpu
    hologram = gpuArray(hologram);
    tempProp = gpuArray(tempProp);
    metric = gpuArray(metric);
end

for phase = z_start:ste:z_end
    
    tempPhase=phase*tempProp;
    hologram = abs(hologram).*exp(1i*tempPhase);
    recon = ift2(hologram);

    for CC=1:Nfoci
        centerx = round(centroids(CC,2));
        centery = round(centroids(CC,1));
        reconcut = recon(max(1,centerx-Npixel-1):min(Xrange,centerx+Npixel),max(1,centery-Npixel-1):min(Yrange,centery+Npixel));
 
        %%%%% VARICANCE AUTOFOCUS %%%%%
        ma = abs(mean(reconcut(:)));
        metric(i,CC) = var(abs(reconcut(:))-ma);
        
        if show_results
            if firstS(CC)
                figure(35123);
                subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC); fociImage(CC) = imagesc(abs(reconcut)); axis square; colormap fire; hold on;
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

if use_gpu
    focusedCuts = gpuArray(zeros(2*(Npixel+1),2*(Npixel+1), Nfoci));
else
    focusedCuts = zeros(2*(Npixel+1), 2*(Npixel+1), Nfoci);
end

index=true(1,1,Nfoci);
nbrPixels=zeros(1,Nfoci);
I=gpuArray(zeros(1,Nfoci));

for CC=1:Nfoci
    a=1;
    b=size(metric,1);
    while true
        [~,I] = max(metric(a:b,CC));
        I = gather(I);
        if I == a
            a=a+1;
        elseif I == b
            b=b-1;
        else
            break
        end
    end
    if isempty(I)
        continue
    end
    I = I+(a-1);
    foci(CC) = x(I); %#ok<AGROW>
    N=round(x(I)/lambda);
    prop_l=N*lambda;
    tempPhase=prop_l*tempProp;
    
    hologram = abs(hologram).*exp(1i*tempPhase);
    recon = fftshift(ifft2(fftshift(hologram)));
    
    centerx = round(centroids(CC,2));
    centery = round(centroids(CC,1));
    rcut = real(recon(max(1,centerx-Npixel-1):min(Xrange,centerx+Npixel),max(1,centery-Npixel-1):min(Yrange,centery+Npixel)));
    focusedCuts(1:size(rcut,1),1:size(rcut,2),CC) = rcut;
    colormap gray;
end

if show_results
    figure(3333);
    try
        plot(x,metric)
    catch
        size(x)
        size(metric)
    end
end

Nfoci=sum(index);

if show_results && Nfoci>0
    figure(34555)
    for CC=1:Nfoci
        subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC); imagesc(focusedCuts(:,:,CC)); axis square; 
        try
            title(['focus at ', num2str(round(x(I(CC)))), ', size ', num2str(nbrPixels(CC))]);
        catch
        end
        colormap gray;
    end
end