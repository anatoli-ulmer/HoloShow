function deconvolved = cluster_deconvolution(handles)

R = handles.clusterradius*1e-9;
x = 1:800;
x = x*75e-6;
theta = atan(x./(handles.detDistance));

switch handles.decon_profile
    case 'guinier'
        q = 4*pi/handles.lambda*sin(theta/2);
        profile = 3*(sin(q.*R)-q.*R.*cos(q.*R)).*q.^(-3)/R^2;
    case 'mie'
        [S2, ang] = mie_prof(R, handles.lambda, handles.cluster_material, handles.mie_precision);
        k = dsearchn((ang*2*pi/360)', theta');
        profile = S2(k);
end

figure(85);
subplot(121);
try
    [minval,ind] = min(handles.reconcutSpec(50:end));
    mie_plot = (abs(profile(50:511))).^2/abs(profile(ind+50)).^2*minval + minval;
catch
    mie_plot = abs(profile(50:511)).^2 + minval;
end
subplot(121); semilogy(50:511, handles.reconSpec(50:511), 50:511, mie_plot); title('power spectrum full image');
subplot(122); semilogy(50:511, handles.reconcutSpec(50:511), 50:511, mie_plot); title('power spectrum full image');

[xx,yy] = meshgrid(-512:511,-512:511);
xx(xx==0)=1;

Freference = profile(round(sqrt(xx.^2+yy.^2)));
Freference = Freference.*handles.mask;
Freference = Freference/max(abs(Freference(:)));
Freference = Freference*sqrt(max(abs(handles.hologram.propagated(:)))/handles.scat_ratio);

deconvolved = handles.hologram.propagated.*conj(Freference);
deconvolved = deconvolved./(abs(Freference).^2+1./sqrt(abs(handles.hologram.propagated)));

% figure(3332); imagesc(abs(Freference))
% deconvolved=hologram.*conj(Freference);
% deconvolved=deconvolved./(abs(Freference));
% deconvolved=deconvolved.*(sqrt(abs(hologram))./ (sqrt(abs(hologram))+1));

