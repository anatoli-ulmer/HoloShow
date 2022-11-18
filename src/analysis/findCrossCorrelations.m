%% modified segmentation algorithm from http://de.mathworks.com/help/images/examples/detecting-a-cell-using-image-segmentation.html
function centroids = findCrossCorrelations(app, hologram, parameter)

show_img = true;
show_segmenation = false;
min_dist = 100;
int_thresh = 5;
r_ignored = 75;
r_dilate = 15;
r_erode = 10;
fudge_factor = 1;
crop_factor = 1;
min_size = 500;
delete_right = true;

% if exist('varargin','var')
%     L = length(varargin);
%     if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
%     for ni = 1:2:L
%         switch lower(varargin{ni})
%             case 'show_img', show_img = varargin{ni+1};
%             case 'min_dist', min_dist = varargin{ni+1}; 
%             case 'int_thresh', int_thresh = varargin{ni+1};
%             case 'r_ignored', r_ignored = varargin{ni+1};
%             case 'r_dilate', r_dilate = varargin{ni+1};
%             case 'r_erode', r_erode = varargin{ni+1};
%             case 'fudge_factor', fudge_factor = varargin{ni+1};
%             case 'crop_factor', crop_factor = varargin{ni+1};
%             case 'min_size', min_size = varargin{ni+1};
%         end
%     end
% end

for p = fieldnames(parameter)'
    eval(sprintf('%s = %f;', p{:}, parameter.(p{:})));
end
%             case 'show_img', show_img = varargin{ni+1};
%             case 'min_dist', min_dist = varargin{ni+1};
%             case 'int_thresh', int_thresh = varargin{ni+1};
%             case 'r_ignored', r_ignored = varargin{ni+1};
%             case 'r_dilate', r_dilate = varargin{ni+1};
%             case 'r_erode', r_erode = varargin{ni+1};
%             case 'fudge_factor', fudge_factor = varargin{ni+1};
%             case 'crop_factor', crop_factor = varargin{ni+1};
%             case 'min_size', min_size = varargin{ni+1};
%         end

if crop_factor>1
    hologram = crop_image(hologram, crop_factor);
    r_ignored = r_ignored/crop_factor;
    min_dist = min_dist/crop_factor;
    r_dilate = ceil(r_dilate/crop_factor);
    r_erode = ceil(r_erode/crop_factor);
    min_size = min_size/crop_factor;
end
recon = ift2(hologram);
[Xrange, Yrange] = size(recon);

%% Step 1: Isolate important parts of patterson function

recon_int = abs(recon); % look only at intensity
[X,Y] = meshgrid(-Xrange/2:Xrange/2-1,-Yrange/2:Yrange/2-1);
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

%% Step 6: Remove small Objects

img_cleared = bwareaopen(img_eroded, min_size); % Remove small Objects
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
    if sum(abs(centroids(n,:) - [513, 513]).^2) < (1*r_ignored)^2
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

if show_segmenation
    h.figure = app.check_figure('segmentation','figure');
    if isempty(h.figure) || ~isgraphics(h.figure)
        h.figure = figure;
        h.figure.Tag = 'segmentation.figure';
        h.tl = tiledlayout(h.figure, 'flow');
        h.axes(1) = nexttile(h.tl);
        h.img(1) = imagesc(img); axis square; colormap fire; title('original image');
        h.axes(2) = nexttile(h.tl);
        h.img(2) = imagesc(img_edges); axis square; colormap fire; title('binary gradient mask');
        h.axes(3) = nexttile(h.tl);
        h.img(3) = imagesc(img_dilated); axis square; title('dilated gradient mask');
        h.axes(4) = nexttile(h.tl);
        h.img(4) = imagesc(img_filled); axis square; title('binary image with filled holes');
        h.axes(5) = nexttile(h.tl);
        h.img(5) = imagesc(img_eroded); axis square; title('segmented image');
        app.handles.segmentation = h;
    end
    app.handles.segmentation.img(1).CData = img;
    app.handles.segmentation.img(2).CData = img_edges;
    app.handles.segmentation.img(3).CData = img_dilated;
    app.handles.segmentation.img(4).CData = img_filled;
    app.handles.segmentation.img(5).CData = img_eroded;

    Npixel = 50;
    hSegRes.figure = app.get_figure('segmentation_results');
    clf(hSegRes.figure);
    for i=1:size(centroids,1)
        hSegRes.ax(i) = subplot(round(sqrt(size(centroids,1))),ceil(sqrt(size(centroids,1))),i,'parent',hSegRes.figure);
        centerx = round(centroids(i,2));
        centery = round(centroids(i,1));
        hSegRes.img(i) = imagesc(hSegRes.ax(i), recon_int(max(1,centerx-Npixel-1):min(Yrange,centerx+Npixel),max(1,centery-Npixel-1):min(Xrange,centery+Npixel))); 
        axis(hSegRes.ax(i), 'image'); colormap(hSegRes.figure, hesperia);
    end

end

if show_img
    
    hCent.figure = app.get_figure('segmentation_centroids');
    clf(hCent.figure);
    hCent.axes(1) = subplot(1,2,1,'parent',hCent.figure); 
    hCent.img(1) = imagesc(hCent.axes(1), log(abs(recon))); axis(hCent.axes(1), 'image');
    hCent.axes(2) = subplot(1,2,2,'parent',hCent.figure); 
    hCent.img(2) = imagesc(hCent.axes(2), ~img_eroded); axis(hCent.axes(2), 'image')
    hCent.axes(2).NextPlot = 'add';
    if ~isempty(centroids)
        hCent.plt(1) = plot(hCent.axes(2), centroids(:,1),centroids(:,2), 'r*');
    end
    colormap(hCent.figure, hesperia);

    if delete_right
        centroids(centroids(:,2)<floor(size(hologram,2)/2), :) = [];
    end
    
    
end

centroids = centroids * crop_factor;
