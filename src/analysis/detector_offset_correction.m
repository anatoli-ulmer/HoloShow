function [hologram, mask_corrected] = detector_offset_correction(hologram, refined_mask, detDistance)

%% shifting
    shift_ud = 0;
    shift_lr = 0;
%     shift_ud = 10;
%     shift_lr = 10;

    hologramSize = size(hologram);
    hologram_shifted = zeros(hologramSize(1) + shift_ud + 1, hologramSize(2) + shift_lr);
    hologram_shifted(1:512, 1:512) = hologram(1:512, 1:512);
    hologram_shifted(end-511+5:end, 1+shift_lr:512+shift_lr) = hologram(end-511+5:end, 1:512);
    hologram_shifted(2:513, 513:1024) = hologram(1:512, end-511:end);
    hologram_shifted(end-511:end, 513+shift_lr:1024+shift_lr) = hologram(end-511:end, end-511:end);

    mask_shifted = ones(size(hologram_shifted));
    mask_shifted(1:512, 1:512) = refined_mask(1:512, 1:512);
    mask_shifted(end-511:end, 1+shift_lr:512+shift_lr) = refined_mask(end-511:end, 1:512);
    mask_shifted(2:513, 513:1024) = refined_mask(1:512, end-511:end);
    mask_shifted(end-511:end, 513+shift_lr:1024+shift_lr) = refined_mask(end-511:end, end-511:end);
%     mask_shifted(1:512,1:end-shift_lr+4) = refined_mask(1:512,:);
%     mask_shifted(end-511:end,1+shift_lr-4:end) = refined_mask(end-511:end,:);

%     uhr_c = [534, 517];
    uhr_c = [538, 513];
%     uhr_c = [500, 500];

%% separate halfes
    uh = hologram_shifted;
    uh(uhr_c(2):end,:) = 0;
    lh = hologram_shifted;
    lh(1:uhr_c(2)-1,:) = 0;

    rmax = 800;
    x=1:rmax;

%% intensity correction
    d1 = detDistance;
    d2 = detDistance-0.003;
    theta1 = x*75e-6/d1;
    theta2 = x*75e-6/d2;
    q_uh = 4*pi/5.3e-9*sin(1/2*atan(theta1));
    q_lh = 4*pi/5.3e-9*sin(1/2*atan(theta2));

%     x_uhr = x(1:length(uhr));
%     x_lhr = x(1:length(lhr));
%     uhr_corr = (d2/d1)^2*uhr.*cos(theta1(x_uhr)).^-3;
%     lhr_corr = lhr.*cos(theta2(x_lhr)).^-3;

%% calculate transmission function
    TMP = bsxfun(@(x,y) abs(x-y), q_lh(:), reshape(q_uh,1,[]));
    [~, idxB] = min(TMP,[],2) ;
    
    xx = -uhr_c(2)+1:size(hologram_shifted,2)-uhr_c(2);
    yy = -uhr_c(1)+1:size(hologram_shifted,1)-uhr_c(1);

    xx(xx==0) = 1;
    yy(yy==0) = 1;

    xxx = sign(xx).*idxB(abs(xx))';
    yyy = sign(yy).*idxB(abs(yy))';

    xxx = xxx + uhr_c(2);
    yyy = yyy + uhr_c(1);

    xxx(xxx>=size(uh,2)) = size(uh,2);
    yyy(yyy>=size(uh,1)) = size(uh,1);
    xxx(xxx<=1) = 1;
    yyy(yyy<=1) = 1;


    uh_corr = (d2/d1)^2*uh(yyy,xxx);
	mask_corrected = mask_shifted(yyy,xxx);
    mask_corrected(uhr_c(1):end,:) = mask_shifted(uhr_c(1):end,:);
    hologram_corrected = lh + uh_corr;
    
%     figure(8000);
%     subplot(131); imagesc(log10(abs(hologram_shifted.*~mask_shifted))); axis square; colormap morgenstemning;
%     subplot(132); imagesc(log10(abs(hologram_corrected))); axis square; colormap morgenstemning;
%     subplot(133); imagesc(log10(abs(hologram_corrected.*~mask_corrected))); axis square; colormap morgenstemning;
%         figure(3334333); clf
%     imagesc(log10(abs(mask_shifted)))
%     hologram_corrected = hologram_corrected.*~mask_corrected;
    hologram = hologram_corrected(31:1024+30,1:1024);
    mask_corrected = ~mask_corrected(31:1024+30,1:1024);
    
    
    
    

    
    
    
    
    
    
    
