function scalebar(haxes, nmPerPixel)

sarray = [10, 20, 50, 100, 200, 500, 1000];
N = floor(haxes.XLim(2));
sc = max(sarray(sarray<N*nmPerPixel/2));

sbarL = sc/nmPerPixel;
sbarW = sbarL/10;

hold on;
rectangle('Position',[N-sbarL-sbarW, N-2*sbarW, sbarL, sbarW], 'facecolor','k')
title(['scalebar = ', num2str(sc), ' nm'])
hold off;