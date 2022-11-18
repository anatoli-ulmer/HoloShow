function app = find_foci(app, hologram, lambda, det_distance, centroids, varargin)
% Copyright (c) 2015, Anatoli Ulmer <anatoli.ulmer@gmail.com>

if size(centroids,1)==0
    foci = 0;
    hFociRes.figure = app.get_figure('foci_results');
    clf(hFociRes.figure);
    return
end

z_start = -50000;
z_end = 50000;
steps = 20;
use_gpu = false;
show_results = false;
show_focusing = true;
crop_factor = 1;
roi_pixels = 80;

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
            case 'show_focusing', show_focusing = varargin{ni+1};
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
Npixel = round(roi_pixels/crop_factor);
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

if app.handles.gpu
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
        
        if show_focusing
            if firstS(CC)
                if CC==1
                    hFoci.figure = app.get_figure('find_foci');
                    clf(hFoci.figure);
                end
                hFoci.axes(CC) = subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC, 'parent', hFoci.figure); 
                fociImage(CC) = imagesc(hFoci.axes(CC), abs(reconcut)); axis(hFoci.axes(CC), 'image'); 
                colormap(hFoci.axes(CC), app.handles.colormap); hold(hFoci.axes(CC), 'on');
                firstS(CC) = false;
            else
                %                 subplot(Nfoci,1,CC);
                fociImage(CC).CData = abs(gather(reconcut));
            end
            drawnow;
        end
    end
    i=i+1;
end


I=zeros(1,Nfoci);
focusedCuts = zeros(2*(Npixel+1), 2*(Npixel+1), Nfoci);

if app.handles.gpu
    I = gpuArray(I);
    focusedCuts = gpuArray(focusedCuts);   
end

index=true(1,1,Nfoci);
nbrPixels=zeros(1,Nfoci);

app.data.foci = nan(1,Nfoci);

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
    app.data.foci(CC) = x(I); %#ok<AGROW>
    N=round(x(I)/lambda);
    prop_l=N*lambda;
    tempPhase=prop_l*tempProp;
    
    hologram = abs(hologram).*exp(1i*tempPhase);
    recon = fftshift(ifft2(fftshift(hologram)));
    
    centerx = round(centroids(CC,2));
    centery = round(centroids(CC,1));
    rcut = real(recon(max(1,centerx-Npixel-1):min(Xrange,centerx+Npixel),max(1,centery-Npixel-1):min(Yrange,centery+Npixel)));
    focusedCuts(1:size(rcut,1),1:size(rcut,2),CC) = rcut;
%     colormap(app.handles.colormap);
end

if show_results
    hFociMet.figure = app.get_figure('foci_metric');
    clf(hFociMet.figure);
    hFociMet.axes = axes(hFociMet.figure);
    try
        plot(hFociMet.axes, x, metric)
    catch
        size(x)
        size(metric)
    end
    app.handles.foci_metric = hFociMet;
end

Nfoci=sum(index);

if show_results
    hFociRes.figure = app.get_figure('foci_results');
    clf(hFociRes.figure);
%     if Nfoci>0
    for CC=1:Nfoci
        hFociRes.axes(CC) = subplot(round(sqrt(Nfoci)),ceil(sqrt(Nfoci)),CC, 'parent', hFociRes.figure); 
        hFociRes.img(CC) = imagesc(hFociRes.axes(CC), focusedCuts(:,:,CC)); axis(hFociRes.axes(CC), 'image'); 
        hFociRes.axes(CC).Title.String = sprintf('focus at %.0f, size = %.0f', app.data.foci(CC), nbrPixels(CC));
        colormap(hFociRes.axes(CC), app.handles.colormap);
    end
%     end
    app.handles.foci_results = hFociRes;
end