function deconvolved = clusterDeconvolution(app, event)

R = app.handles.clusterradius*1e-9;
xRange = 1:800;
xRange = xRange*75e-6;
theta = atan(xRange./(app.handles.detDistance));
q = 4*pi/app.handles.lambda*sin(theta/2);

switch app.handles.decon_profile
    case 'guinier'
        profile = 3*(sin(q.*R)-q.*R.*cos(q.*R)).*q.^(-3)/R^3;
    case 'mie'
        [S2, ang] = mie_prof(R, app.handles.lambda, app.handles.cluster_material, app.handles.mie_precision);
        k = dsearchn((ang*2*pi/360)', theta');
        profile = S2(k);
end


[xx,yy] = meshgrid(-512:511,-512:511);
xx(xx==0)=1;

Freference = profile(round(sqrt(xx.^2+yy.^2)));
Freference = Freference.*app.handles.mask;
% Freference = Freference/max(abs(Freference(:)));
% Freference = Freference*sqrt(max(abs(app.handles.hologram.masked(:))))/...
%                                 (1 + 10^-(app.handles.scat_ratio));
%                             max(abs(Freference(:)))/sqrt(max(abs(app.handles.hologram.masked(:))))
%                             sum(abs(Freference(:)).^2)/sum(abs(app.handles.hologram.masked(:)))
Freference = Freference/sum(abs(Freference(:)).^2);
Freference = Freference*sum(abs(app.handles.hologram.masked(:)))*10^-(app.handles.scat_ratio);

deconvolved = app.handles.hologram.masked.*conj(Freference);
deconvolved = deconvolved./(abs(Freference).^2+1./sqrt(abs(app.handles.hologram.masked)));
% deconvolved = deconvolved./(abs(Freference).^2+1/5^2);
% max(abs(Freference(:)).^2)
% deconvolved = app.handles.hologram.masked./Freference;


% figure(3332);
% imagesc(log10(abs(deconvolved)))

% figure(3332); imagesc(abs(Freference))
% deconvolved=hologram.*conj(Freference);
% deconvolved=deconvolved./(abs(Freference));
% deconvolved=deconvolved.*(sqrt(abs(hologram))./ (sqrt(abs(hologram))+1));

% PLOTTING

if app.handles.HPfiltering; lowerBound = max(app.handles.HPfrequency,50); else lowerBound = 50; end
if app.handles.LPfiltering; upperBound = min(app.handles.LPfrequency,511); else upperBound = 511; end
xRange = lowerBound:upperBound;

[maxval,~] = max(app.data.hologram.spectrum(xRange));
% [maxval,~] = max(app.data.hologram.spectrum);
mie_plot = abs(profile(xRange)).^2;
mie_plot = mie_plot/max(mie_plot) * maxval;
 
[minval,ind] = min(app.data.hologram.spectrum(xRange));
profile_plot = abs(profile(xRange)).^2;
profile_plot = profile_plot/profile_plot(ind) * minval;


app.handles.hologram.propagated = propagateHologram(deconvolved, app.handles.phase, app.handles.lambda, app.handles.detDistance, app.handles.cut_center);
recon = ift2(app.handles.hologram.propagated);
ROI = app.data.recon.roi;
reconcut = recon(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));

[decon_plot, xD] = rmean(abs(ft2(zeropadding(reconcut))).^2);

% decon_plot = abs(decon_plot).^2;
%figure(22221); imagesc(-real(reconcut)); axis square;

figure(86);
% subplot(221); semilogy(x, app.data.hologram.spectrum(x), x, profile_plot); title('power spectrum full image');
subplot(222); semilogy(xRange, app.data.hologram.spectrum(xRange), xRange, profile_plot); title('power spectrum ROI');
subplot(223); semilogy(xRange, decon_plot(xRange), xRange, profile_plot); title('power spectrum deconvolved');
subplot(224); semilogy(xRange, app.data.hologram.spectrum(xRange), xRange, decon_plot(xRange)/max(decon_plot(xRange))*max(app.data.hologram.spectrum(xRange))); title('power spectrum deconvolved');

figure(87);
semilogy(q(xRange)*1e-9, app.data.hologram.spectrum(xRange), q(xRange)*1e-9, profile_plot, '-', ...
q(xRange)*1e-9, decon_plot(xRange),  'black', q(xRange)*1e-9, q(xRange).^-4 * 3.5e32, '--' );
legend('raw spectrum', 'reference spectrum', 'deconvolved spectrum', 'q^{-4}');
xlabel('q [nm^{-1}]'); ylabel('I [a.u.]');

