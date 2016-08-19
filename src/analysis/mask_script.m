function handles_return = mask_script(handles)
% Performs:
%     - common mode correction
%     - shifting of scattering pattern and mask


%% PARAMETERS

HP_filter = handles.HPfiltering;
HP_radius = handles.HPfrequency;
LP_filter = handles.LPfiltering;
LP_radius = handles.LPfrequency;%332;%
CM_thresh = 50;
rowsToshift = round(handles.ycenter);
columnsToShift =  round(handles.xcenter);
slit = handles.slit;
shift = handles.shift
SMOOTH_FACTOR = 15; % smooth parameter for mask
HP_SMOOTH_FACTOR = 100; % smooth parameter for HP filter

% Switches for what to show
showMASKS = false; % show used mask
showCM = false; % show common mode correction
showSMOOTH = false; % show smoothed mask and pattern

%% LOAD DATA & MASK

origdata = handles.hologram.orig;
origdata(origdata==0) = 1e-10;
origdata(abs(origdata)>=15000) = 0; % set saturated pixels to 0
origmask = handles.origmask;
drawnMask = handles.drawnMask;

%0???     PIXEL_IS_PERFECT = 0
%1     PIXEL_IS_INVALID = 1
%2     PIXEL_IS_SATURATED = 2
%3     PIXEL_IS_HOT = 4
%4     PIXEL_IS_DEAD = 8
%5     PIXEL_IS_SHADOWED = 16
%6     PIXEL_IS_IN_PEAKMASK = 32
%7     PIXEL_IS_TO_BE_IGNORED = 64
%8     PIXEL_IS_BAD = 128
%9     PIXEL_IS_OUT_OF_RESOLUTION_LIMITS = 256
%10    PIXEL_IS_MISSING = 512
%11     PIXEL_IS_NOISY = 1024
%12     PIXEL_IS_ARTIFACT_CORRECTED = 2048
%13     PIXEL_FAILED_ARTIFACT_CORRECTION = 4096
%14     PIXEL_IS_PEAK_FOR_HITFINDER = 8192
%15     PIXEL_IS_PHOTON_BACKGROUND_CORRECTED = 16384

mask = ones(1024);
% 
% for n=1:1024 % select bad pixels and convert to binary mask
%     temp = de2bi(origmask(n,:));
%     test = [temp, zeros(1024,16-size(temp,2))];
%     mask(n,:)=test(:,1)+test(:,2)+test(:,3)+test(:,4)+test(:,5)+test(:,7)+test(:,10);%+test(:,13)+test(:,8);%+test(:,11);
% end
load('src/files/binary_mask.mat');

mask = ~mask; % invert and convert to binary
mask(490:557,485:553)=0;
mask(origdata<-50)=0;
mask(origdata==0)=0;

maskModified = mask.*drawnMask;
maskModified(origdata==0)=0;

if showMASKS
    figure(11) %#ok<*UNRCH>
    subplot(221); imagesc(origmask); axis square;
    subplot(222); imagesc(mask);axis square;
    subplot(223); imagesc(mask>0);axis square;
    subplot(224); imagesc(maskModified>0);axis square;
end

maskold = maskModified;

%% CENTER PICTURE & COMMON MODE

mask = maskold;
data = origdata;

% CORRECTION OF CENTER SHIFT
data = circshift(data,[rowsToshift columnsToShift]);
mask = circshift(mask,[rowsToshift columnsToShift]);

% SECOND CORRECTION THROUH VARIANCE AND DETECTOR SHIFTS
sdata = circshift(data,[slit, shift]);
smask = circshift(mask,[slit, shift]);
data(513+slit:end,:) = sdata(513+slit:end,:);
mask(513+slit:end,:) = smask(513+slit:end,:);
data(isnan(data)) = 0;

% HIGHPASS FILTERING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Modified see below!
if HP_filter
    [X, Y] = meshgrid(-512:511,-512:511);
    lowp = X.^2+Y.^2<HP_radius^2;
    mask(lowp)=0;
end

% LOWPASS FILTERING
if LP_filter
    [X, Y] = meshgrid(-512:511,-512:511);
    highp = X.^2+Y.^2>LP_radius^2;
    mask(highp)=0;
end

% COMMON MODE CORRECTION
for m=1:1024
    dat = data(1:512-columnsToShift,m);
    dat = dat(mask(1:512-columnsToShift,m)>0);
    dat = dat(dat<CM_thresh);
    CM = median(dat);
    if ~isnan(CM)
        data(1:512-columnsToShift,m) = data(1:512-columnsToShift,m)-CM.*mask(1:512-columnsToShift,m);
    end
    
    dat = data(513-columnsToShift:1024,m);
    dat = dat(mask(513-columnsToShift:1024,m)>0);
    dat = dat(dat<CM_thresh);
    CM = median(dat);
    if ~isnan(CM)
        data(513-columnsToShift:1024,m) = data(513-columnsToShift:1024,m)-CM.*mask(513-columnsToShift:1024,m);
    end
end

% mask = mask.*(abs(data)<1.5e4);
data(data<30)=0;

if showCM
    figure(22);
    subplot(221);
    imagesc(log(abs(origdata)).*mask,[0 8]);
    colormap(fire);
    axis square;
    subplot(222);
    imagesc(mask);
    axis square;
    subplot(223); imagesc(log(abs(data)).*mask,[0 max(log(abs(data(:))))]); axis square;
end

oldmask = mask;
olddata = data;

%% SMOOTH MASK
data = olddata;
mask = oldmask;

blurred=imgaussfilt(mask,SMOOTH_FACTOR);
newMask = 1-(blurred<0.99);
newMask=imgaussfilt(newMask,SMOOTH_FACTOR);

% if HP_filter
%     [X, Y] = meshgrid(-512:511,-512:511);
%     HP = X.^2+Y.^2<HP_radius^2;
%     HP = double(~HP>0);
%     
%     HPmask = (1./(1+exp(-(sqrt(X.^2+Y.^2)-HP_radius-HP_SMOOTH_FACTOR)/HP_SMOOTH_FACTOR)));
%     HPmask = HPmask-min(HPmask(:));
%     HPmask = HPmask./max(HPmask(:));
%     HPmask(~HP)=0;
%     newMask = newMask.*HPmask;
%     mask = mask.*HP;
% end

newMask(~mask)=0;

if showSMOOTH
    figure(3);
    subplot(121); imagesc(newMask); axis square; colormap gray; colorbar;
    subplot(122); imagesc(log(abs(newMask)),[0 8]); axis square; colormap fire; colorbar;
end

handles.mask =newMask;
handles.hardmask = mask;
handles.hologram.masked = data.*newMask;

handles_return = handles;
