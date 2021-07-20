function set_colormap(str, ax)

if ~exist('ax','var')
    ax = gca;
end
switch str
    case 'r2b'
        colormap(ax,r2b);
    case 'jet'
        colormap(ax,jet);
    case 'ms'
        colormap(ax,morgenstemning);
    case 'gray'
        colormap(ax,gray);
    case 'hsv'
        colormap(ax,hsv);
end