function clusterradius = find_decon(handles)

%%%%%%%%%%%% TO DO: THIS IS COMPLETELY F****D UP! %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% needs to be cleaned. look in cluster_deconvolution.m!" %%%%%%


radii=(10:1:50)*1e-9;
x = 1:800;
x = x*75e-6;
theta = atan(x./(handles.detDistance));
q = 4*pi/handles.lambda*sin(theta/2);

[xx,yy] = meshgrid(-512:511,-512:511);
xx(xx==0)=1;

figure(23446); holoI = imagesc(part_and_scale(handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3)),...
        handles.logSwitch, handles.partSwitch)); axis square; drawnow;
    
for i=1:length(radii)
    R = radii(i);
    switch handles.decon_profile
        case 'guinier'
            guinier = 3*(sin(q.*R)-q.*R.*cos(q.*R)).*q.^(-3)/R^2;
            Freference = guinier(round(sqrt(xx.^2+yy.^2)));
        case 'mie'
            [S2, ang] = mie_prof(R, handles.lambda, handles.cluster_material, handles.mie_precision);
            k = dsearchn((ang*2*pi/360)', theta');
            mie = S2(k);
            Freference = mie(round(sqrt(xx.^2+yy.^2)));
        otherwise
            handles.decon_profile = input('Please specify cluster material (Kr or Xe):','s');
            continue
    end
                
    Freference = Freference/sum(abs(Freference(:)));
    Freference = Freference.*handles.mask;
    Freference = Freference*sum(abs(handles.hologram.propagated(:)))/handles.scat_ratio;
    
    deconvolved=handles.hologram.propagated.*conj(Freference);
    deconvolved=deconvolved./(abs(Freference).^2+1./sqrt(abs(handles.hologram.propagated)));
    
    handles.recon = fftshift(ifft2(fftshift(deconvolved)));
    
    reconcut = part_and_scale(handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3)),...
        handles.logSwitch, handles.partSwitch);
    
    holoI.CData = reconcut; 
    title(['cluster radius = ', num2str(radii(i)*1e9)]); drawnow;
    
end

clusterradius = 1;
