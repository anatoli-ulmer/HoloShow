function output = power_spectrum(data,varargin)

twodim=false;
zeroN=0;
if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case '2d', twodim = varargin{ni+1};
            case 'zeropadding', zeroN = varargin{ni+1};
        end
    end
end

if zeroN
    Fdata = fftshift(fft2(fftshift(data),zeroN,zeroN));
else
    Fdata = fftshift(fft2(fftshift(data),zeroN,zeroN));
end

radprof = rmean(abs(Fdata));

if twodim
    [X,Y] = size(Fdata);
    [x,y] = meshgrid(-X/2:X/2-1,-Y/2:Y/2-1);
    
    output = sqrt(x.^2+y.^2)+1;
    output(output>min(X,Y)/2-1) = min(X,Y)/2-1;
    output = radprof(floor(output));
else
    output = radprof;
end
