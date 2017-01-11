function deconvolved = cluster_deconvolution(hologram, mask, clusterradius, reconSpec, wiener, lambda, det_Dist)

R=clusterradius*1e-9;
x = 1:800;
x = x*75e-3;
theta = atan(x./(det_Dist*1e3));
q = theta*2*pi/lambda;
G = 3*(sin(q.*R)-q.*R.*cos(q.*R)).*q.^(-3)/R^2;

figure(85);
subplot(121);
try
    [M,I] = max(reconSpec(50:end));
    Gplot = abs(G(50:511))/abs(G(I+50))*M;
catch
    Gplot = abs(G(50:511));
end
subplot(121); hold on; semilogy(50:511,Gplot); title('power spectrum full image'); hold off;
subplot(122); hold on; semilogy(50:511,Gplot); title('power spectrum full image'); hold off;

[xx,yy] = meshgrid(-512:511,-512:511);
xx(xx==0)=1;
Freference = G(round(sqrt(xx.^2+yy.^2)));
Freference = Freference.*mask;
Freference = Freference/max(abs(Freference(:)));
Freference = Freference*max(sqrt(abs(hologram(:)))/5);

deconvolved=hologram.*conj(Freference);
deconvolved=deconvolved./(abs(Freference).^2+1./sqrt(abs(hologram)));

% figure(3332); imagesc(abs(Freference))
% deconvolved=hologram.*conj(Freference);
% deconvolved=deconvolved./(abs(Freference));
% deconvolved=deconvolved.*(sqrt(abs(hologram))./ (sqrt(abs(hologram))+1));

