function set_colormap(str)

switch str
    case 'jet'
        colormap jet;
    case 'fire'
        colormap fire;
    case 'gray'
        colormap gray;
    case 'hsv'
        colormap hsv;
end