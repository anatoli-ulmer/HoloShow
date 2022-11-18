function app = clusterDeconvolution(app, event)
tic
% R = app.handles.clusterradius*1e-9;
% xRange = 1:725;
% pxRange = xRange*75e-6;
% theta = atan(pxRange./(app.handles.detDistance));
% q = 4*pi/app.handles.lambda*sin(theta/2);
% app.handles.mie_precision = xRange(end);
% app.handles.mie_maxang = theta(end)/pi*180;
% 
% % app.handles.decon_profile = 'mie';
% 
% switch app.handles.decon_profile
%     case 'guinier'
%         profile = 3*(sin(q.*R)-q.*R.*cos(q.*R)).*q.^(-3)/R^3;
%     case 'mie'
%         [S2, ~] = mie_prof(R, app.handles.lambda, app.handles.cluster_material, app.handles.mie_precision, app.handles.mie_maxang);
% %         k = dsearchn((ang*2*pi/360)', theta');
% %         profile = S2(k);
%         profile = S2;
% end
% 
% 
% [xx,yy] = meshgrid(-512:511,-512:511);
% xx(xx==0)=1;
% 
% ref_field = profile(round(sqrt(xx.^2+yy.^2)));

% New reference calculation method
radius = app.handles.clusterradius*1e-9;
wavelength = app.handles.lambda;
material = app.handles.cluster_material;
n_pix = size(app.handles.hologram.masked, 1);
px_size = app.handles.detPixelsize;
detector_distance = app.handles.detDistance;
method = app.handles.decon_profile;
[ref_field, ref_profile, q] = calc_diffraction_field(radius, wavelength, ...
    material, n_pix, px_size, detector_distance, method);





% ref_field = ref_field/max(abs(ref_field(:)));
% ref_field = ref_field*sqrt(max(abs(app.handles.hologram.masked(:))))/...
%                                 (1 + 10^-(app.handles.scat_ratio));
%                             max(abs(ref_field(:)))/sqrt(max(abs(app.handles.hologram.masked(:))))
%                             sum(abs(ref_field(:)).^2)/sum(abs(app.handles.hologram.masked(:)))
% ref_field = ref_field/sum(abs(ref_field(:).*app.handles.mask(:)).^2);
% disp(app.handles.scat_ratio)
% ref_field = ref_field*sum(abs(app.handles.hologram.masked(:)))*10^(app.handles.scat_ratio);

ref_field = ref_field/norm(ref_field.*app.handles.mask, 'fro');
ref_field = ref_field*norm(app.handles.hologram.masked, 'fro')*10^(app.handles.scat_ratio);


% % % % ref_field = ref_field.*app.handles.mask;
% % % 
% % % % ref_field = ref_field/norm(ref_field(:), 'fro');
% % % % ref_field = ref_field*norm(app.handles.hologram.masked(:), 'fro')*10^-(app.handles.scat_ratio);

% deconvolved = app.handles.hologram.masked.*conj(ref_field);
% deconvolved = deconvolved./(abs(ref_field).^2+1./sqrt(abs(app.handles.hologram.masked)));

deconvolved = app.handles.hologram.masked.*conj(ref_field).*sqrt(abs(app.handles.hologram.masked));
deconvolved = deconvolved./(1 + abs(ref_field).^2.*sqrt(abs(app.handles.hologram.masked)));
% % % 
% % % % deconvolved = deconvolved./(abs(ref_field).^2+1/5^2);
% % % % max(abs(ref_field(:)).^2)
% % % % deconvolved = app.handles.hologram.masked./ref_field;


% figure(3332);
% imagesc(log10(abs(deconvolved)))

% figure(3332); imagesc(abs(ref_field))
% deconvolved=hologram.*conj(ref_field);
% deconvolved=deconvolved./(abs(ref_field));
% deconvolved=deconvolved.*(sqrt(abs(hologram))./ (sqrt(abs(hologram))+1));

% PLOTTING

% if ;  = max(app.handles.HPfrequency,50); else lowerBound = 50; end
% if app.handles.LPfiltering; upperBound = min(app.handles.LPfrequency,511); else upperBound = 511; end

app.calc_rmean_range();
pxRange = app.handles.rmean.range;

[maxval,~] = max(app.data.hologram.spectrum(pxRange));
% [maxval,~] = max(app.data.hologram.spectrum);
mie_plot = abs(ref_profile(pxRange)).^2;
mie_plot = mie_plot/max(mie_plot) * maxval;
 
[minval,ind] = min(app.data.hologram.spectrum(pxRange));
profile_plot = abs(ref_profile(pxRange)).^2;
profile_plot = profile_plot/profile_plot(ind) * minval;


app.handles.hologram.propagated = propagateHologram(deconvolved, app.handles.phase, app.handles.lambda, app.handles.detDistance, app.handles.cut_center);
recon = ift2(app.handles.hologram.propagated);
ROI = app.data.recon.roi;
reconcut = recon(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));

Freconcut = abs(ft2(zeropadding(reconcut))).^2;

[decon_plot, xDecon, app.handles.rmeanbins] = rmean(Freconcut, pxRange([1,end]), [], app.handles.rmean.bins);
% decon_plot = abs(decon_plot).^2;
%figure(22221); imagesc(-real(reconcut)); axis square;
% 
% figure(86);
% % subplot(221); semilogy(x, app.data.hologram.spectrum(x), x, profile_plot); title('power spectrum full image');
% subplot(222); semilogy(pxRange, app.data.hologram.spectrum(pxRange), pxRange, profile_plot); title('power spectrum ROI');
% subplot(223); semilogy(pxRange, decon_plot(pxRange), pxRange, profile_plot); title('power spectrum deconvolved');
% subplot(224); semilogy(pxRange, app.data.hologram.spectrum(pxRange), pxRange, decon_plot(pxRange)/max(decon_plot(pxRange))*max(app.data.hologram.spectrum(pxRange))); title('power spectrum deconvolved');

if ~isfield(app.handles,'deconPlotFigure') || ~isgraphics(app.handles.deconPlotFigure)
    app.handles.deconPlotFigure = figure(87);
    app.handles.deconPlotAxes = axes(app.handles.deconPlotFigure);
    app.handles.deconPlotPlots = semilogy(q(pxRange)*1e-9, app.data.hologram.spectrum(pxRange), q(pxRange)*1e-9, profile_plot, '-', ...
        q(pxRange)*1e-9, decon_plot(pxRange),  'black' );
        legend(app.handles.deconPlotAxes, 'raw spectrum', 'reference spectrum', 'deconvolved spectrum', 'q^{-4}');
        xlabel(app.handles.deconPlotAxes, 'q [nm^{-1}]'); ylabel(app.handles.deconPlotAxes, 'I [a.u.]');
        grid(app.handles.deconPlotAxes, 'on')
else
    app.handles.deconPlotPlots(1).YData = app.data.hologram.spectrum(pxRange);
    app.handles.deconPlotPlots(2).YData = profile_plot;
    app.handles.deconPlotPlots(3).YData = decon_plot(pxRange);
%     app.handles.deconPlotPlots(4).YData = q(pxRange).^-4 * 3.5e32;
end


app.handles.deconvolution.ref_field = ref_field;
app.handles.hologram.deconvoluted = deconvolved;
toc