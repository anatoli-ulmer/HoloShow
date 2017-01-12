%% modified segmentation algorithm from http://de.mathworks.com/help/images/examples/detecting-a-cell-using-image-segmentation.html
function centroids = find_CC(recon, varargin)

show_img = true;
min_dist = 100;
int_thresh = 5;
r_ignored = 75;
r_dilate = 15;
r_erode = 10;
fudge_factor = 1;

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'show_img', show_img = varargin{ni+1};
            case 'min_dist', min_dist = varargin{ni+1};
            case 'int_thresh', int_thresh = varargin{ni+1};
            case 'r_ignored', r_ignored = varargin{ni+1};
            case 'r_dilate', r_dilate = varargin{ni+1};
            case 'r_erode', r_erode = varargin{ni+1};
            case 'fudge_factor', fudge_factor = varargin{ni+1};
        end
    end
end

%% Step 1: Isolate important parts of patterson function

recon_int = abs(recon); % look only at intensity
[X,Y] = meshgrid(-512:511,-512:511);
img = recon_int.*(X.^2 + Y.^2 > r_ignored^2); % center part (autocorrelation) is ignored
img(img<int_thresh*median(img(:))) = 0; % minimum intensity threshold

%% Step 2: Sobel Edge detection

if fudge_factor == 1
    [img_edges, ~] = edge(img, 'sobel'); 
else
    [~, threshold] = edge(img, 'sobel'); 
    img_edges = edge(img,'sobel', threshold * fudge_factor);
end

%% Step 3: Dilate the Image

se_dilate = strel('disk', r_dilate);
img_dilated = imdilate(img_edges, se_dilate);

%% Step 4: Fill Interior Gaps

img_filled = imfill(img_dilated, 'holes');
% img_filled = imclearborder(img_filled, 4); % Remove Connected Objects on Border 

%% Step 5: Smoothen the Object

se_erode = strel('disk', r_erode);
img_eroded = imerode(img_filled, se_erode);

%% Step 5: Remove small Objects

img_cleared = bwareaopen(img_eroded, 500); % Remove small Objects
% BWfinal = BWfinal - bwareaopen(BWfinal, 10000); % Remove big Objects

%% Step 6: Find connected areas

connected_components = bwconncomp(img_cleared, 8);
S = regionprops(connected_components, 'Centroid');
centroids = cat(1, S.Centroid);
if size(centroids,1)==0
    centroids = [0,0];
    return
end

%% Step 7: Remove CCs near center

n=1;
while true
    if n>size(centroids,1)
        break
    end
    if sum(abs(centroids(n,:) - [513, 513]).^2) < (1.5*r_ignored)^2
        centroids(n,:) = [];
    else
        n=n+1;
    end
end

%% Step 8: Merge neighbored CC positions

n=1;
while n<=size(centroids,1)
    ctmp = (centroids - (repmat(centroids(n,:), size(centroids,1) ,1)));
    dist = ctmp(:,1).^2 + ctmp(:,2).^2 < min_dist^2;
    if sum(dist)>1
        k = find(dist);
        centroids(n,:) = mean(centroids(k,:));
        for j=2:sum(dist) 
            centroids(k(j),:) = [];
        end
    else
        n=n+1;
    end
end

%% Show outcome

if show_img
    figure(4);
    subplot(331); imagesc(img); axis square; colormap fire; title('original image');
    subplot(332); imagesc(img_edges); axis square; colormap fire; title('binary gradient mask');
    subplot(333); imagesc(img_dilated); axis square; title('dilated gradient mask');
    subplot(334); imagesc(img_filled); axis square; title('binary image with filled holes');
    subplot(335); imagesc(img_eroded); axis square; title('segmented image');

    figure(41)
    subplot(121); imagesc(log(abs(recon))); axis square;
    subplot(122); imagesc(~img_eroded)
    hold on
    plot(centroids(:,1),centroids(:,2), 'r*')
    hold off
    axis square; colormap fire;
    
    Npixel = 50;
    figure(42)
    
    for i=1:size(centroids,1)
        subplot(round(sqrt(size(centroids,1))),ceil(sqrt(size(centroids,1))),i);
        centerx = round(centroids(i,2));
        centery = round(centroids(i,1));
        imagesc(recon_int(max(1,centerx-Npixel-1):min(1024,centerx+Npixel),max(1,centery-Npixel-1):min(1024,centery+Npixel))); axis square; colormap fire;
    end
    
end