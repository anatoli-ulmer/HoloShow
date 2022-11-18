function app = find_focus(app, hologram, lambda, det_distance, ROI, minPhase, ...
    maxPhase, steps, af_method, showHOLO, gpuSwitch, makeGIF, crop_factor)
% Copyright (c) 2016, Anatoli Ulmer <anatoli.ulmer@gmail.com>

fprintf('looking for focus ...\n');

if nargin<10
    crop_factor = false;
end
if nargin<9
    gpuSwitch = false;
end
if nargin<8
    showHOLO = false;
end

if crop_factor > 1
    hologram = crop_image(hologram, crop_factor);
    ROI = round(ROI/crop_factor);
    sprintf('cropped by %s', crop_factor);
end

% [Xrange, Yrange] = size(hologram);
% PX_SIZE = 75e-6;
% H_center_q=Xrange/2+1;
% H_center_p=Yrange/2+1;
% [p,q] = meshgrid(1:Xrange, 1:Yrange);

tempProp=(2*pi/(lambda*1e9))*(1-((app.handles.detPixelsize/app.handles.detDistance)^2)*((app.data.xx).^2+ (app.data.yy).^2)).^(1/2); % plane wave propagation
% tempProp=-pi*lambda*(PX_SIZE/CCD_S_DIST)^2*((q-H_center_q).^2+ (p-H_center_p).^2); % Fresnel Rayleigh propagator
ste = (maxPhase-minPhase)/steps;

i=1;

firstS = true;
% x = minPhase:ste:maxPhase;
x = linspace(minPhase, maxPhase, steps);
metric = zeros(length(x),1);
focusplot = zeros(round(ROI(4))+1,steps);

if strcmp(af_method, 'all')
    metric2 = nan(length(x),1);
    metric3 = nan(length(x),1);
    metric4 = nan(length(x),1);
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
        focusplot = gpuArray(focusplot);
    catch
        warning('Error in GPU allocation')
    end
end

tic
% recon = ift2(hologram);
% reconcut = recon(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
% hologram = ft2(reconcut);
% tempProp = imresize(tempProp, size(hologram))/numel(hologram)*numel(tempProp);

reconcut = zeros(ROI(4),ROI(3));

 app.handles.focusFigure = findobj('Tag', 'find_focus_figure');
 if isempty(app.handles.focusFigure) || ~isgraphics(app.handles.focusFigure)
     app.handles.findFocusFigure = figure(200); clf(app.handles.focusFigure);
     app.handles.findFocusFigure.Tag = 'find_focus_figure';
     app.handles.findFocusFigure.Name = 'find_focus_figure';
     app.handles.findFocusFigure.Interruptible = 0;
     app.handles.findFocusFigure.Position(3:4) = [600, 275];
     app.handles.findFocusFigure.Position(1:2) = app.handles.reconstruction.figure.Position(1:2) - [0, app.handles.findFocusFigure.Position(4)];
     app.handles.findFocusAxes = gobjects(1,3);
     app.handles.findFocusPlt = gobjects(1);
     app.handles.findFocusImg = gobjects(1,2);
     app.handles.findFocusTL = tiledlayout(app.handles.findFocusFigure, 2, 4, 'Padding', 'compact');
     app.handles.findFocusAxes(1) = nexttile(app.handles.findFocusTL, [2 2]);
     app.handles.findFocusImg(1) = imagesc(app.handles.findFocusAxes(1), real(gather(reconcut))); axis(app.handles.findFocusAxes(1), 'image');
     app.handles.findFocusAxes(2) = nexttile(app.handles.findFocusTL, [1 2]);
     app.handles.findFocusPlt(1) = plot(app.handles.findFocusAxes(2), x, gather(metric));
     app.handles.findFocusAxes(3) = nexttile(app.handles.findFocusTL, [1 2]);
     app.handles.findFocusImg(2) = imagesc(app.handles.findFocusAxes(3), abs(gather(focusplot)));
 end

D = parallel.pool.DataQueue;
D.afterEach(@(focusplot) updatePlot(app.handles.findFocusImg(2), abs(focusplot)));



D2 = parallel.pool.DataQueue;
D2.afterEach(@(reconcut) updatePlot(app.handles.findFocusImg(1), real(reconcut)));

% ROI

for i = 1:numel(x)
    phase = x(i);
    tempPhase=phase*tempProp;
    
    recon = ift2(abs(hologram).*exp(1i*tempPhase));
    reconcut = recon(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3)); %#ok<PFBNS> 
    focusplot(:,i) = reconcut(:,round(ROI(3)/2));
    
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
    if showHOLO || phase==maxPhase
        if firstS
            try %#ok<TRYNC>
%                 close(3)
                close(656)
            end
            if makeGIF
                filename = 'Propagation.gif';
                gifFigure = figure(656);
%                 set(gifFigure,'Position', [100, 100, 356, 356]);
                gifFrame = imagesc(real(reconcut)); axis image; colormap gray; hold on; caxis([-1.2,1.2]); set(gca,'xtick',[]); set(gca,'ytick',[]);set(gca,'position',[0 0 1 1],'units','normalized')
                %             colormap(b2r(-2,2));
                frame = getframe(656);
                [im, map] = rgb2ind(frame.cdata,256);
                if ~exist(filename,'file')
                    imwrite(im,map,filename,'gif', 'Loopcount',inf);
                end
            end         
            
%             focusFigure.Units = 'normalized';
%             set(focusFigure,'Name','find focus','Position', [0.1,0.3,0.5,0.2]);
%             subplot(231); pl1 = imagesc(real(reconcut)); axis square; colormap gray; hold on; set(gca,'xtick',[]); set(gca,'ytick',[])
%             subplot(2,3,[2,3]); pl2 = plot(x(1:length(x)), metric(1:length(x))); grid on;
%             xlim(x([1,end]))
%             subplot(2,3,[5,6]); pl3 = imagesc(abs(focusplot)); 
%             %pbaspect([2 1 1])
%             firstS = false;
        end
        app.handles.findFocusImg(1).CData = real(reconcut);
        app.handles.findFocusPlt(1).YData(i) = metric(i);
        app.handles.findFocusImg(2).CData = abs(focusplot);
        if makeGIF
            set(gifFrame, 'CData', real(reconcut));
        end
        
        if makeGIF
            frame = getframe(656);
            fr = rgb2ind(frame.cdata,map);
            imwrite(fr,map,filename,'gif','WriteMode','append','DelayTime',0);
        end
%         if mod(phase,10*ste) == 0
            drawnow;
%         end
    end
%     i=i+1;
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
app.data.focus = focus;
app.handles.phase = app.data.focus;
fprintf(' done! \n');
