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

IA=imageA;
IB=imageB;
N=length(IA);

[X,Y]=meshgrid(-N/2:N/2-1,-N/2:N/2-1);
out=zeros(1,floor(N/2-ringwidth));
Np=zeros(1,floor(N/2-ringwidth));
ring=zeros(N);

for rad=1:floor(N/2-ringwidth)
    ring(X.^2+Y.^2<(ringwidth+rad).^2)=1;
    ring(X.^2+Y.^2<rad.^2)=0; 
    
    Np(rad)=sum(ring(:));
    
    IAring=IA.*ring;
    IBring=IB.*ring;
    
    temp=IAring.*conj(IBring);
    
    normA=abs(IAring).^2;
    normB=abs(IBring).^2;
    
    out(rad)=sum(temp(:))/sqrt(sum(normA(:))*sum(normB(:)));
end

FRCout=abs(out);
twoSigma = 2./(sqrt(Np/2));
halfBit = (0.2071+1.9102./sqrt(Np))./(1.2071+0.9102./sqrt(Np));

