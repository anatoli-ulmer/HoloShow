function focus = find_focus(hologram, ROI, minPhase, maxPhase, steps, showHOLO, gpuSwitch, makeGIF)
% Copyright (c) 2015, Anatoli Ulmer <anatoli.ulmer@gmail.com>

fprintf('looking for focus ...\n');

if nargin<7
    gpuSwitch=false;
end
if nargin<6
    showHOLO = false;
end

[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
CCD_S_DIST = 0.735;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
lambda = 1.053;
[p,q] = meshgrid(1:Xrange, 1:Yrange);

tempProp=(2*pi/lambda)*(1-((PX_SIZE/CCD_S_DIST)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2);
% tempProp=-pi*lambda*(PX_SIZE/CCD_S_DIST)^2*((q-H_center_q).^2+ (p-H_center_p).^2); % Fresnel Rayleigh propagator
ste = (maxPhase-minPhase)/steps;

i=1;

firstS = true;
x = minPhase:ste:maxPhase;
variance = zeros(length(x),1);

if gpuSwitch
    variance = gpuArray(variance);
    tempProp = gpuArray(tempProp);
    hologram = gpuArray(hologram);
end

for phase = minPhase:ste:maxPhase
    
    N=round(phase/lambda);
    prop_l=N*lambda;
    tempPhase=prop_l*tempProp;
    
    hologram = abs(hologram).*exp(1i*tempPhase);
    recon = fftshift(ifft2(fftshift(hologram)));
    reconcut = recon(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
    variance(i) = var(abs(reconcut(:)));
    
    if showHOLO
        if firstS
            try %#ok<TRYNC>
                close(3)
                close(656)
            end
            if makeGIF
                filename = 'Propagation.gif';
                gifFigure = figure(656);
                set(gifFigure,'Position', [100, 100, 356, 356]);
                gifFrame = imagesc(real(reconcut)); axis square; colormap gray; hold on; caxis([-1.2,1.2]); set(gca,'xtick',[]); set(gca,'ytick',[]);set(gca,'position',[0 0 1 1],'units','normalized')
                %             colormap(b2r(-2,2));
                frame = getframe(656);
                [im, map] = rgb2ind(frame.cdata,256);
                if ~exist(filename,'file')
                    imwrite(im,map,filename,'gif', 'Loopcount',inf);
                end
            end
            
            focusFigure = figure(3);
            focusFigure.Units = 'normalized';
            set(focusFigure,'Name','find focus','Position', [0.1,0.3,0.5,0.2]);
            subplot(131); pl1 = imagesc(real(reconcut)); axis square; colormap gray; hold on; set(gca,'xtick',[]); set(gca,'ytick',[])
            subplot(1,3,[2,3]); pl2 = plot(x(1:length(x)), variance(1:length(x))); grid on;
            firstS = false;
        else
            set(pl1, 'CData', real(gather(reconcut)));
            set(pl2, 'ydata', gather(variance(1:length(x))));
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

[~,I] = max(variance);
% variance = [x; variance']';

focus = x(I);
fprintf(' done! \n');