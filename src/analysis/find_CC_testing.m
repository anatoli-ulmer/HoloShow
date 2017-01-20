%% modified segmentation algorithm from http://de.mathworks.com/help/images/examples/detecting-a-cell-using-image-segmentation.html
function centroids = find_CC_testing(hologram, varargin)

show_img = true;
min_dist = 100;
int_thresh = 5;
r_ignored = 75;
r_dilate = 30;
r_erode = 20;
fudge_factor = 1;
crop = 1;

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
            case 'crop', crop = varargin{ni+1};
        end
    end
end

% s1 = sum(sum(abs(hologram(1:512,1:512))))
% s2 = sum(sum(abs(hologram(1:512,513:end))))
% s3 = sum(sum(abs(hologram(513:end,513:end))))
% s4 = sum(sum(abs(hologram(513:end,1:512))))

if crop>1
    hologram = crop_image(hologram, crop);
    r_ignored = r_ignored/crop;
    min_dist = min_dist/crop;
    r_dilate = ceil(r_dilate/crop);
    r_erode = ceil(r_erode/crop);
    sprintf('cropping not integrated yet!');
end
recon = ift2(hologram);
[Xrange, Yrange] = size(recon);

%% Step 1: Isolate important parts of patterson function

recon_int = abs(recon); % look only at intensity
[X,Y] = meshgrid(-Xrange/2:Xrange/2-1,-Yrange/2:Yrange/2-1);
img = recon_int.*(X.^2 + Y.^2 > r_ignored^2); % center part (autocorrelation) is ignored

imgtemp = img;

med = median(img(:));
img(img<5*med) = med; % minimum intensity threshold

%% Step 2: Sobel Edge detection

if fudge_factor == 1
    [img_edges, ~] = edge(img, 'sobel'); 
else
    [~, threshold] = edge(img, 'sobel'); 
    img_edges = edge(img,'sobel', threshold * fudge_factor);
end

img = imgaussfilt(imgtemp, 10);
med = median(img(:));
img(img<3*med) = med; 


%% Step 3: Dilate the Image

se_dilate = strel('disk', r_dilate);
img_dilated = imdilate(img_edges, se_dilate);

%% Step 4: Fill Interior Gaps

img_filled = imfill(img_dilated, 'holes');
% img_filled = imclearborder(img_filled, 4); % Remove Connected Objects on Border 

%% Step 5: Smoothen the Object

se_erode = strel('disk', r_erode);
img_eroded = imerode(img_filled, se_erode);

%% Step 6: Remove small Objects

img_cleared = bwareaopen(img_eroded, 500/crop); % Remove small Objects
% BWfinal = BWfinal - bwareaopen(BWfinal, 10000); % Remove big Objects

%% Step 7: Find connected areas

connected_components = bwconncomp(img_cleared, 8);
S = regionprops(connected_components, 'Centroid');
centroids = cat(1, S.Centroid);
if size(centroids,1)==0
    centroids = [0,0];
    return
end

%% Step 8: Remove CCs near center

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

%% Step 9: Merge neighbored CC positions

n=1;
while true
    if n>size(centroids,1)
        break
    end
    ctmp = (centroids - (repmat(centroids(n,:), size(centroids,1) ,1)));
    dist = ctmp(:,1).^2 + ctmp(:,2).^2 < min_dist^2;
    if sum(dist)>1
        k = find(dist);
        centroids(n,:) = mean(centroids(k,:));
        for j=sum(dist):-1:2
            centroids(k(j),:) = [];
        end
    end
    n=n+1;
end

%% Show results

if show_img
    figure(4);
    subplot(231); imagesc(img); axis square; colormap fire; title('original image');
    subplot(232); imagesc(img_edges); axis square; colormap fire; title('binary gradient mask');
    subplot(233); imagesc(img_dilated); axis square; title('dilated gradient mask');
    subplot(234); imagesc(img_filled); axis square; title('binary image with filled holes');
    subplot(235); imagesc(img_eroded); axis square; title('segmented image');

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
        imagesc(recon_int(max(1,centerx-Npixel-1):min(Yrange,centerx+Npixel),max(1,centery-Npixel-1):min(Xrange,centery+Npixel))); axis square; colormap fire;
    end
    
end

centroids = centroids * crop;