function [imageA,imageB] = split_dataset(input,varargin)

% Split the input dataset into two downsampled sets by following algorithm
% from: 
% Hantke, M., Hasse, D., Maia, F. et al. High-throughput imaging of heterogen-
% eous cell organelles with an X-ray laser. Nature Photon 8, 943–949 (2014).
% https://doi.org/10.1038/nphoton.2014.270
%
% 1. Divide the input image into 4x4 super-pixels.
% 2. For each of the super-pixels select 8 pixels at random.
% 3. Average the selected pixels and assign the result to the corresponding downsampled
%    pixel in output image 1.
% 4. Average the remaining 8 pixels (those not selected in step 3) and assign the result
%    to the corresponding down-sampled pixel in output image 2.

superpixelsize=4;

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'superpixelsize', superpixelsize = varargin{ni+1};
        end
    end
end

Npixel = size(input)/superpixelsize; % must be divisible by superpixelsize
superpixelmatrix = mat2cell(input, superpixelsize*ones(1,Npixel(1)), superpixelsize*ones(1,Npixel(2)));

imageA=zeros(Npixel);
imageB=zeros(Npixel);

for i=1:Npixel(1)
    for j=1:Npixel(2)
        superpixel=superpixelmatrix(i,j);
        [imageA(i,j), imageB(i,j)] = divide_superpixel(superpixel);
    end
end

imageA=imageA/8;
imageB=imageB/8;


function [pixel1, pixel2] = divide_superpixel(superpixel)

    superpixel=cell2mat(superpixel);
    superpixelsize=length(superpixel);

    % get random indices

    nSets=2; %number of sets
    pixelarray=1:superpixelsize^2; % sample pixels
    ind=pixelarray(randperm(superpixelsize^2)); % a random permutation of your data
    ind=reshape(ind,numel(pixelarray)/nSets,nSets); % reshape so that each col is a 'set'

    pixel1=sum(superpixel(ind(:,1)));
    pixel2=sum(superpixel(ind(:,2)));
