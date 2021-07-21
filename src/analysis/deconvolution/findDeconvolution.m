function clusterradius = findDeconvolution(app, event)

%%%%%%%%%%%% TO DO: THIS IS COMPLETELY F****D UP! %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% needs to be cleaned. look in cluster_deconvolution.m!" %%%%%%


radii=(10:2:app.handles.clusterradius)*1e-9;
x = 1:800;
x = x*75e-6;
theta = atan(x./(app.handles.detDistance));
q = 4*pi/app.handles.lambda*sin(theta/2);

[xx,yy] = meshgrid(-512:511,-512:511);
xx(xx==0)=1;

figure(23446); holoI = imagesc(part_and_scale(app.handles.recon(app.data.recon.roi(2):app.data.recon.roi(2)+app.data.recon.roi(4),app.data.recon.roi(1):app.data.recon.roi(1)+app.data.recon.roi(3)),...
        app.handles.partSwitch)); axis square; drawnow;
    
for i=1:length(radii)
    R = radii(i);
    switch app.handles.decon_profile
        case 'guinier'
            guinier = 3*(sin(q.*R)-q.*R.*cos(q.*R)).*q.^(-3)/R^2;
            Freference = guinier(round(sqrt(xx.^2+yy.^2)));
        case 'mie'
            [S2, ang] = mie_prof(R, app.handles.lambda, app.handles.cluster_material, app.handles.mie_precision);
            k = dsearchn((ang*2*pi/360)', theta');
            mie = S2(k);
            Freference = mie(round(sqrt(xx.^2+yy.^2)));
        otherwise
            app.handles.decon_profile = input('Please specify cluster material (Kr or Xe):','s');
            continue
    end
                
    Freference = Freference/sum(abs(Freference(:)));
    Freference = Freference.*app.handles.mask;
    Freference = Freference*sum(abs(app.handles.hologram.propagated(:)))/app.handles.scat_ratio;
    
    deconvolved=app.handles.hologram.propagated.*conj(Freference);
    deconvolved=deconvolved./(abs(Freference).^2+1./sqrt(abs(app.handles.hologram.propagated)));
    
    app.handles.recon = fftshift(ifft2(fftshift(deconvolved)));
    
    reconcut = part_and_scale(app.handles.recon(app.data.recon.roi(2):app.data.recon.roi(2)+app.data.recon.roi(4),app.data.recon.roi(1):app.data.recon.roi(1)+app.data.recon.roi(3)),...
        app.handles.partSwitch);
    
    holoI.CData = reconcut; 
    title(['cluster radius = ', num2str(radii(i)*1e9)]); drawnow;
    
    [decon_plot, xD] = rmean(abs(deconvolved).^2);
    
    figure(860); clf
    semilogy(abs(decon_plot)); hold on; 
    semilogy(app.handles.spectrumHolo);
    
end

clusterradius = 1;
