function deconvolved = cluster_deconvolution(handles)

R = handles.clusterradius*1e-9;
x = 1:800;
x = x*75e-6;
theta = atan(x./(handles.detDistance));

switch handles.decon_profile
    case 'guinier'
        q = 4*pi/handles.lambda*sin(theta/2);
        profile = 3*(sin(q.*R)-q.*R.*cos(q.*R)).*q.^(-3)/R^3;
    case 'mie'
        [S2, ang] = mie_prof(R, handles.lambda, handles.cluster_material, handles.mie_precision);
        k = dsearchn((ang*2*pi/360)', theta');
        profile = S2(k);
end

[xx,yy] = meshgrid(-512:511,-512:511);
xx(xx==0)=1;

Freference = profile(round(sqrt(xx.^2+yy.^2)));
Freference = Freference.*handles.mask;
Freference = Freference/max(abs(Freference(:)));
Freference = Freference*sqrt(max(abs(handles.hologram.masked(:)))/handles.scat_ratio);

deconvolved = handles.hologram.masked.*conj(Freference);
deconvolved = deconvolved./(abs(Freference).^2+1./sqrt(abs(handles.hologram.masked)));

% figure(3332);
% imagesc(log10(abs(deconvolved)))

% figure(3332); imagesc(abs(Freference))
% deconvolved=hologram.*conj(Freference);
% deconvolved=deconvolved./(abs(Freference));
% deconvolved=deconvolved.*(sqrt(abs(hologram))./ (sqrt(abs(hologram))+1));

% PLOTTING

if handles.HPfiltering; lowb = max(handles.HPfrequency,50); else lowb = 50; end
if handles.LPfiltering; upb = min(handles.LPfrequency,511); else upb = 511; end
x = lowb:upb;

% [maxval,~] = max(handles.reconcutSpec(lowb:upb));
% mie_plot = abs(profile(lowb:upb)).^2;
% mie_plot = mie_plot/max(mie_plot) * maxval;

[minval,ind] = min(handles.reconcutSpec(x));
profile_plot = abs(profile(x)).^2;
profile_plot = profile_plot/profile_plot(ind) * minval;
decon_plot = rscan(abs(deconvolved).^2, 'dispflag', false);
% decon_plot = abs(decon_plot).^2;

figure(86);
subplot(221); semilogy(x, handles.reconSpec(x), x, profile_plot); title('power spectrum full image');
subplot(222); semilogy(x, handles.reconcutSpec(x), x, profile_plot); title('power spectrum ROI');
subplot(223); semilogy(x, decon_plot(x), x, profile_plot); title('power spectrum deconvolved');


