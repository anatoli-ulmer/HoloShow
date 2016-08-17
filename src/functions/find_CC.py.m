% http://www.scipy-lectures.org/advanced/image_processing/auto_examples/plot_find_edges.html

import scipy
from scipy import ndimage

im = scipy.misc.imread('bike.jpg')


%% Step 1: Read Image

fudgeFactor = 0.5;
% Iorig = dlmread('testRecon.dat');
Iorig = abs(recon);
[X,Y] = meshgrid(-512:511,-512:511);
I = Iorig.*(X.^2+Y.^2>100^2);
I(I<5*median(I(:))) = 0;
[grad, direction] = imgradient(I);

%% Step 2: Detect Entire Cell

[~, threshold] = edge(I, 'sobel');
processed = scipy.ndimage.filters.sobel(im, 0)
BWs = edge(I,'sobel', threshold * fudgeFactor);


%% Step 3: Dilate the Image

se90 = strel('line', 5, 90);
se0 = strel('line', 5, 0);

BWsdil = imdilate(BWs, [se90 se0]);

%% Step 4: Fill Interior Gaps

BWdfill = imfill(BWsdil, 'holes');
% figure, imshow(BWdfill);

%% Step 5: Remove Connected Objects on Border

BWnobord = imclearborder(BWdfill, 4);


%% Step 6: Smoothen the Object

seD = strel('disk',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);


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


%%

BWfinal = bwareaopen(BWfinal, 500);
BWfinal = BWfinal - bwareaopen(BWfinal, 10000);


CC = bwconncomp(BWfinal,8);
S = regionprops(CC,'Centroid');
centroids = cat(1, S.Centroid);
if size(centroids,1)==0
    centroids = [0,0];
    return
end
