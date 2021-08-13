function [FRCout, twoSigma, halfBit, imageA, imageB] = FRC(image,varargin)

realspace=false;
superpixelsize=4;
ringwidth=3;

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'realspace', realspace = varargin{ni+1};
            case 'superpixelsize', superpixelsize = varargin{ni+1};
            case 'ringwidth', ringwidth = varargin{ni+1}; 
        end
    end
end

[imageA,imageB] = split_dataset(image,'superpixelsize',superpixelsize);

if realspace
    imageA=fftshift(fft2(fftshift(imageA)));
    imageB=fftshift(fft2(fftshift(imageB)));
end

nPixel=size(imageA);

[X,Y]=meshgrid(-nPixel(2)/2:nPixel(2)/2-1,-nPixel(1)/2:nPixel(1)/2-1);
out=zeros(1,floor(max(nPixel)/2-ringwidth));
nPixelRing=zeros(1,floor(max(nPixel)/2-ringwidth));
ring=zeros(nPixel);

for ringRadius=1:floor(nPixel/2-ringwidth)
    ring(X.^2+Y.^2<(ringwidth+ringRadius).^2)=1;
    ring(X.^2+Y.^2<ringRadius.^2)=0; 
    
    nPixelRing(ringRadius)=sum(ring(:));
    
    IAring=imageA.*ring;
    IBring=imageB.*ring;
    
    temp=IAring.*conj(IBring);
    
    normA=abs(IAring).^2;
    normB=abs(IBring).^2;
    
    out(ringRadius)=sum(temp(:))/sqrt(sum(normA(:))*sum(normB(:)));
end

FRCout=abs(out);
twoSigma = 2./(sqrt(nPixelRing/2));
halfBit = (0.2071+1.9102./sqrt(nPixelRing))./(1.2071+0.9102./sqrt(nPixelRing));

