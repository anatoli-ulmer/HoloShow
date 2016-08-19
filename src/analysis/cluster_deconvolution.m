function deconvolved = cluster_deconvolution(hologram, mask, clusterradius, reconSpec, wiener)

R=clusterradius*1e-9;
x = 1:800;
x = x*75e-3;
lambda = 1.0530e-9;
theta = atan(x./735);
q = theta*2*pi/lambda;
G = 3*(sin(q.*R)-q.*R.*cos(q.*R)).*q.^(-3)/R^2;

% figure(34234); semilogy(abs(G(1:511)));
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
Freference = Freference/max(abs(Freference(:)));
Freference = Freference.*mask;
Freference = Freference*max(abs(hologram(:)));

% figure(23444); imagesc(log10(abs(Freference))); axis square

deconvolved=hologram.*conj(Freference);
% deconvolved=deconvolved./(abs(Freference).^2+wiener);
deconvolved=deconvolved./(abs(Freference).^2+wiener);
