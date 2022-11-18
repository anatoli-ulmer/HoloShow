function [aArray, rArray, bins] = rmean(I, rRange, rCenter, bins)
% RMEAN  Radially average complex valued 2D matrix 'I' until maximum 
% pixel radius 'rRange' around pixel position 'rCenter'.
% 
% [aArray, rArray] = RMEAN(I)
% 
% [aArray, rArray] = RMEAN(I, rMax)
% 
% [aArray, rArray] = RMEAN(I, [rMin, rMax])
% 
% [aArray, rArray] = RMEAN(I, [rMin, rMax], rCenter)
%
% [aArray, rArray] = RMEAN(I, [rMin, rMax], rCenter) 

% computes the complex valued mean of pixels lying on circles with radii in the 
% range from 'rMin' to 'rMax', where the units of 'rMin' and 'rMax' are in 
% pixels. 'rMin is 1 and 'rMax' is 
% calculated by 'rMax = max(size(I))/2', if it was not specified. The 
% center of each circle is given by 'rCenter = [yCenter, xCenter]' and is 
% calculated by 'rCenter = ceil(size(I)/2)', if it was not specified. 
% The unit of rCenter is absolute pixel positions. The radial average can 
% be computed beyond the the edge and in the corners of the matrix I, if 
% rMax is larger than the distance to the edge. The radial average is 
% returned in 'aArray' and the mid-points of the average bins are 
% returned in 'rArray'. Not a Number (NaN) values are excluded from 
% the calculation. 
%
% Example
% TO DO: write example
%
% INPUT
% I = (complex valued) input matrix to be radially averaged
% rMax = maximum to be computed averaging radius in pixels
% rCenter = origin of radial averaging in absolute pixel values
%
% OUTPUT
% aArray = (complex valued) radial average vector
% rArray = midpoints of the bins, that were used for radial averaging
%
% See also linspace, meshgrid
% (c) 2014 David J. Fischer | fischer@shoutingman.com
% 4/4/14 DJF first working version
% 5/2/14 DJF documentation & radialavg_tester.m to demonstrate use
% radial distances r over grid of z
% 6/20/16 DJF Excludes NaN values
% 6/21/16 DJF Added origin offset
% 
% 2020-08-18 Changes by Anatoli Ulmer | anatoli.ulmer@gmail.com
%   - adaption of output variable type to input variable type and added 
%     complex value computation
%   - changed inputs to (I,rMax,rCenter)
%   - changed units of rMax and rCenter = [yCenter,xCenter] to absolute 
%     pixel values
% 2021-12-16 Changes by Anatoli Ulmer | anatoli.ulmer@gmail.com
%   - added rMin
    
    %%%%% begin init %%%%%
    
    nPixel = size(I, [1,2]);
    
    if ~exist('rCenter','var') || isempty(rCenter)
        rCenter = floor(nPixel/2)+1;
    end
    if ~exist('rRange','var') || isempty(rRange)
        rRange = [1, max(nPixel)/2 * ones(1,'like',I)];
    end

    if numel(rRange)>2
        calcArray = rRange;
        rMin = calcArray(1);
        rMax = calcArray(end);
    else
        rMin = rRange(1);
        rMax = rRange(end); 
        if numel(rRange)==1, rMin = 1; end
        calcArray = rMin:rMax;
    end
    
    xx = nan(nPixel, 'like', I);
    yy = nan(nPixel, 'like', I);
    rMatrix = nan(nPixel, 'like', I);
    rbins = linspace(0,rMax+1,rMax+1);
    
    
    % radial positions are midpoints of the bins(:,:)
%     notNans = ~isnan(I); % identify NaNs in input data
    
    %%%%% end init %%%%%
    
    % [xx(:,:), yy(:,:)] = meshgrid(linspace(-nPixel(1)/2,nPixel(1)/2,nPixel(1)), ...
    %     linspace(-nPixel(2)/2,nPixel(2)/2,nPixel(2)));
    
    [xx(:,:), yy(:,:)] = meshgrid( (1:nPixel(2))-rCenter(2), ...
        (1:nPixel(1))-rCenter(1) );
    rMatrix(:,:) = sqrt( (xx).^2 + (yy).^2);
    
    aArray = nan(1,rMax,'like', I); % vector for radial average
    % ravgR = 0:ravgMax-1;
    rArray = (rbins(1:end-1)+rbins(2:end))/2;
    

    % loop over the bins(:,:), except the final (r=1) position
    
    if nargout < 3
        bins = true(nPixel);
        for j = calcArray
            % find all matrix locations whose radial distance is in the jth bin
            bins(:,:) = rMatrix>=rbins(j) & rMatrix<rbins(j+1);
            aArray(j) = mean(I(bins), 'omitnan');
        end    
    else
        if ~exist('bins', 'var') || numel(bins) ~= numel(calcArray) || isempty(bins)
            for j = calcArray
                bins{j} = rMatrix>=rbins(j) & rMatrix<rbins(j+1);
            end
            for j = calcArray
                aArray(j) = mean(I(bins{j}), 'omitnan');
            end
        end
    end
    
%         % count the number of those locations
%         n = sum(bins(:));
%         if n~=0
%             % average the values at those binned locations
%             aArray(j) = sum(I(bins))/n;
%         end
%     end
    
%     bins(:,:) = rMatrix>=rbins(rMax) & rMatrix<rMax;
%     aArray(rMax) = nanmean(I(bins));
    
%     n = sum(bins(:));
    
%     if n~=0
%         % average the values at those binned locations
%         aArray(rMax) = sum(I(bins))/n;
%     end
