function deconvolved = cluster_deconvolution(hologram, mask, clusterradius, reconSpec, wiener, lambda, detDistance)

R = clusterradius*1e-9;
x = 1:800;
x = x*75e-6;
theta = atan(x./(detDistance));
q = 4*pi/lambda*sin(theta/2);
guinier = 3*(sin(q.*R)-q.*R.*cos(q.*R)).*q.^(-3)/R^2;

figure(85);
subplot(121);
try
    [maxval,ind] = max(reconSpec(50:end));
    guinier_plot = abs(guinier(50:511))/abs(guinier(ind+50))*maxval;
catch
    guinier_plot = abs(guinier(50:511));
end
subplot(121); hold on; semilogy(50:511,guinier_plot); title('power spectrum full image'); hold off;
subplot(122); hold on; semilogy(50:511,guinier_plot); title('power spectrum full image'); hold off;

[xx,yy] = meshgrid(-512:511,-512:511);
xx(xx==0)=1;
Freference = guinier(round(sqrt(xx.^2+yy.^2)));
Freference = Freference.*mask;
Freference = Freference/max(abs(Freference(:)));
Freference = Freference*max(sqrt(abs(hologram(:)))/5);

deconvolved = hologram.*conj(Freference);
deconvolved = deconvolved./(abs(Freference).^2+1./sqrt(abs(hologram)));

% figure(3332); imagesc(abs(Freference))
% deconvolved=hologram.*conj(Freference);
% deconvolved=deconvolved./(abs(Freference));
% deconvolved=deconvolved.*(sqrt(abs(hologram))./ (sqrt(abs(hologram))+1));

