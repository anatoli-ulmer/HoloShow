function focus = find_focus(hologram, lambda, CCD_S_DIST, ROI, minPhase, maxPhase, steps, af_method, showHOLO, gpuSwitch, makeGIF)
% Copyright (c) 2016, Anatoli Ulmer <anatoli.ulmer@gmail.com>

fprintf('looking for focus ...\n');

if nargin<9
    gpuSwitch=false;
end
if nargin<8
    showHOLO = false;
end

[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
[p,q] = meshgrid(1:Xrange, 1:Yrange);

tempProp=(2*pi/(lambda*1e9))*(1-((PX_SIZE/CCD_S_DIST)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2); % plane wave propagation
% tempProp=-pi*lambda*(PX_SIZE/CCD_S_DIST)^2*((q-H_center_q).^2+ (p-H_center_p).^2); % Fresnel Rayleigh propagator
ste = (maxPhase-minPhase)/steps;

i=1;

firstS = true;
x = minPhase:ste:maxPhase;
metric = zeros(length(x),1);

if strcmp(af_method, 'all')
    metric2 = zeros(length(x),1);
    metric3 = zeros(length(x),1);
    metric4 = zeros(length(x),1);
end

if gpuSwitch
    try
        metric = gpuArray(metric);
        if strcmp(af_method, 'all')
            metric2 = gpuArray(metric2);
            metric3 = gpuArray(metric3);
            metric4 = gpuArray(metric4);
        end
        tempProp = gpuArray(tempProp);
        hologram = gpuArray(hologram);
    catch
        warning('Error in GPU allocation')
    end
end

tic
for phase = minPhase:ste:maxPhase
    
    tempPhase=phase*tempProp;
    
    hologram = abs(hologram).*exp(1i*tempPhase);
    recon = ift2(hologram);
    reconcut = recon(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
    
    switch af_method
        case 'variance'
            %%%%% VARIANCE AUTOFOCUS %%%%%
            ma = mean(abs(reconcut(:)));
            metric(i) = var(abs(reconcut(:))-ma);
        case 'gradient'
            %%%%% GRADIENT AUTOFOCUS %%%%%
            [FX,FY] = gradient(abs(reconcut));
            metric(i) = sum(sum(sqrt(FX.^2 + FY.^2)));
        case 'spectral'
            %%%%% SPECTRAL AUTOFOCUS %%%%%
            SPEC = abs(ft2(abs(reconcut))).^2;
            metric(i) = sum(sum(log10(1 + SPEC)));
        case 'laplacian'
            %%%%% LAPLACE AUTOFOCUS %%%%%
            metric(i) = sum(sum(del2(abs(reconcut)).^2));
        case 'all'
            ma = mean(abs(reconcut(:)));
            metric(i) = var(abs(reconcut(:))-ma);
            
            [FX,FY] = gradient(abs(reconcut));
            metric2(i) = sum(sum(sqrt(FX.^2 + FY.^2)));
            
            SPEC = abs(ft2(abs(reconcut))).^2;
            metric3(i) = sum(sum(log10(1 + SPEC)));

            metric4(i) = sum(sum(del2(abs(reconcut)).^2));
    end
    if showHOLO
        if firstS
            try %#ok<TRYNC>
%                 close(3)
                close(656)
            end
            if makeGIF
                filename = 'Propagation.gif';
                gifFigure = figure(656);
%                 set(gifFigure,'Position', [100, 100, 356, 356]);
                gifFrame = imagesc(real(reconcut)); axis square; colormap gray; hold on; caxis([-1.2,1.2]); set(gca,'xtick',[]); set(gca,'ytick',[]);set(gca,'position',[0 0 1 1],'units','normalized')
                %             colormap(b2r(-2,2));
                frame = getframe(656);
                [im, map] = rgb2ind(frame.cdata,256);
                if ~exist(filename,'file')
                    imwrite(im,map,filename,'gif', 'Loopcount',inf);
                end
            end
            
            focusFigure = figure(3);
            clf(focusFigure)
%             focusFigure.Units = 'normalized';
%             set(focusFigure,'Name','find focus','Position', [0.1,0.3,0.5,0.2]);
            subplot(131); pl1 = imagesc(real(reconcut)); axis square; colormap gray; hold on; set(gca,'xtick',[]); set(gca,'ytick',[])
            subplot(1,3,[2,3]); pl2 = plot(x(1:length(x)), metric(1:length(x))); grid on;
            pbaspect([2 1 1])
            firstS = false;
        else
            set(pl1, 'CData', real(gather(reconcut)));
            set(pl2, 'ydata', gather(metric(1:length(x))));
            if makeGIF
                set(gifFrame, 'CData', real(reconcut));
            end
        end
        
        if makeGIF
            frame = getframe(656);
            fr = rgb2ind(frame.cdata,map);
            imwrite(fr,map,filename,'gif','WriteMode','append','DelayTime',0);
        end
            
        drawnow;
    end
    i=i+1;
end
toc
if strcmp(af_method, 'all')
    figure(33);
    plot(x, metric/max(metric), x, metric2/max(metric2), x, metric3/max(metric3), x, metric4/max(metric4));
    legend('VAR', 'GRA', 'SPEC', 'LAP');
end

% var = [x; variance']';

while true
    [~,I] = max(metric);
    switch x(I)
        case x(1)
            x(1) = [];
            metric(1) = [];
        case x(end)
            x(end) = [];
            metric(end) = [];
        otherwise
            break
    end
end


focus = x(I);
fprintf(' done! \n');