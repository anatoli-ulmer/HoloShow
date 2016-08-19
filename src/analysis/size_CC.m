function nbrPixels = size_CC(recon)

% show the shit?
yessss = false;

%% Step 1: Read Image

fudgeFactor = 0.5;

I = abs(recon);
I(I<5*median(I(:))) = 0;
[grad, direction] = imgradient(I);

if yessss
    figure(4788);
    subplot(331); imagesc((I)); axis square; colormap fire;
    title('original image');
end
%% Step 2: Detect Entire Cell

[~, threshold] = edge(I, 'sobel');
% fudgeFactor = 1;
BWs = edge(I,'sobel', threshold * fudgeFactor);
if yessss
    subplot(332); imagesc(BWs); axis square; colormap fire; title('binary gradient mask');
end
% BWs = I;
%% Step 3: Dilate the Image

se90 = strel('line', 5, 90);
se0 = strel('line', 5, 0);

BWsdil = imdilate(BWs, [se90 se0]);

if yessss
    subplot(333); imagesc(BWsdil); axis square; title('dilated gradient mask');
end
% figure, imshow(BWsdil), title('dilated gradient mask');

%% Step 4: Fill Interior Gaps

BWdfill = imfill(BWsdil, 'holes');
% figure, imshow(BWdfill);
if yessss
    subplot(334); imagesc(BWdfill); axis square; title('binary image with filled holes');
end
%% Step 5: Remove Connected Objects on Border

BWnobord = imclearborder(BWdfill, 4);
% figure, imshow(BWnobord),
if yessss
    subplot(335); imagesc(BWnobord); axis square; title('cleared border image');
end
%% Step 6: Smoothen the Object

seD = strel('disk',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
% figure, imshow(BWfinal),
if yessss
    subplot(336); imagesc(BWfinal); axis square; title('segmented image');
end

%% Step 7: Detect largest Area

% use Area and PixelIdxList in regionprops, this means to edit the to the following line:

% stat = regionprops(BWfinal,'Centroid','Area','PixelIdxList');
% % The maximum area and it's struct index is given by
%
% [maxValue,index] = max([stat.Area]);
% % The linear index of pixels of each area is given by `stat.PixelIdxList', you can use them to delete that given area (I assume this means to assign zeros to it)
% BWnew = BWfinal;
% BWnew(stat(index).PixelIdxList) = 0;
%
% BWfinal = BWfinal-BWnew;
%
% subplot(337); imagesc(BWfinal); axis square;
% title('choose largest area');

%% Shrink

H = fspecial('gaussian',5,5);
BWshrink = imfilter(BWfinal,H,'replicate');
BWshrink = double(BWshrink>0.999);

if yessss
    subplot(338); imagesc(BWshrink); axis square;
    title('shrink area');
end

% %% Show
% BWfinal = BWshrink;
% BWoutline = bwperim(BWfinal);
% showH = real(hologram(ROI(1,1):ROI(1,2),ROI(2,1):ROI(2,2)));
% showH = showH + abs(min(showH(:)));
% Segout = showH;
% Segout(BWoutline) = max(showH(:));
% subplot(339); imagesc(Segout);
% axis square; colormap fire; title('outlined original image');

%%

BWfinal = bwareaopen(BWfinal, 500);
BWfinal = BWfinal - bwareaopen(BWfinal, 10000);

if yessss
    subplot(339); imagesc(BWfinal); axis square;
    title('remove small objects');
end
nbrPixels=sum(BWfinal(:));
