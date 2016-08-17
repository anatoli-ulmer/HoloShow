function clusterradius = find_decon(handles)

R=10:1:50;
FRC_cutoff=zeros(1,length(R));

x = 1:800;
x = x*75e-3;
lambda = 1.0530e-9;
theta = atan(x./735);
q = theta*2*pi/lambda;
[xx,yy] = meshgrid(-512:511,-512:511);
xx(xx==0)=1;

figure(23446); holoI = imagesc(part_and_scale(handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3)),...
        handles.logSwitch, handles.partSwitch)); axis square; drawnow;

% varmap = zeros(1,length(R));
    
for i=1:length(R)
    rad = R(i)*1e-9;
    G = 3*(sin(q.*rad)-q.*rad.*cos(q.*rad)).*q.^(-3)/rad^2;
    Freference = G(round(sqrt(xx.^2+yy.^2)));
    Freference = Freference/max(abs(Freference(:)));
    Freference = Freference.*handles.mask;
    Freference = Freference*max(abs(handles.hologram.propagated(:)))/2;
    
    deconvolved=handles.hologram.propagated.*conj(Freference);
    deconvolved=deconvolved./(abs(Freference).^2+handles.wiener);
    
    handles.recon = fftshift(ifft2(fftshift(deconvolved)));
    
    holocut = part_and_scale(handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3)),...
        handles.logSwitch, handles.partSwitch);
    
%     varmap(i) = var(abs(holocut(:)));
    
    holoI.CData = holocut; 
    title(num2str(R(i))); drawnow;
    
    
    temp = FRC(holocut(1:2*(floor(end/2)),1:2*(floor(end/2))),'realspace',true,'superpixelsize',2,'ringwidth',2);
    try
        FRC_cutoff(i) = find(temp(6:end)<0.5,1);
    end
end

% figure(3245); plot(R,varmap);

figure(443)
plot(R,FRC_cutoff)
title('FRC cutoff over cluster radius');

[~,I] = max(FRC_cutoff);
clusterradius = R(I);
