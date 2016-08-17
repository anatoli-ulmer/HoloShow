[X,Y] = meshgrid(-512:511,-512:511);

sig = kugel(50)+kugel(20,[-40,-40]);
Fsig = fftshift(fft2(fftshift(sig)));
Fsig(X.^2+Y.^2<30^2)=0;



rect=@(x,a) ones(1,numel(x)).*(abs(x)<a/2); % a is the width of the pulse
% x=-10:0.001:10
% y=rect(x,2)   
% plot(x,y)

h=-2*30*sinc(2*30*sqrt(X.^2+Y.^2));
h(513,513)=0;

Fsig = Fsig.*h;
Rsig = real(fftshift(ifft2(fftshift(Fsig))));


figure(234);
imagesc(h)
imagesc(log10(abs(Fsig)))
imagesc(((Rsig)))
axis square;

%%

    HP = X.^2+Y.^2<30^2;
    HP = double(~HP>0);
    
%     HPmask = (1./(1+exp(-(sqrt(X.^2+Y.^2)-30-100)/100)));
    HPmask = 1-exp(-sqrt(X.^2+Y.^2)/5^2);
%     HPmask = HPmask-min(HPmask(:));
%     HPmask = HPmask./max(HPmask(:));
%     HPmask(~HP)=0;

FM =fftshift(fft2(fftshift(HPmask)));
FM(513,513)=0;
figure(235);
imagesc(HPmask)
imagesc((real(FM)>0))
% imagesc(log10(abs(FM)))
axis square;