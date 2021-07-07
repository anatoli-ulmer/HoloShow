function reconScalebar(ax, nmPerPixel)

sarray = [10, 20, 50, 100, 200, 500, 1000];
N = floor(ax.XLim(2));
sc = max(sarray(sarray<N*nmPerPixel/2));

sbarL = sc/nmPerPixel;
sbarW = sbarL/10;

hold(ax, 'on');
rectangle('Position',[N-sbarL-sbarW, N-2*sbarW, sbarL, sbarW], 'facecolor','k', ...
    'parent', ax)
title(ax, ['scalebar = ', num2str(sc), ' nm'])
hold(ax, 'off');
