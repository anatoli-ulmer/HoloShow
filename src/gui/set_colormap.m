function set_colormap(str)

switch str
    case 'jet'
        colormap jet;
    case 'ms'
        colormap morgenstemning;
    case 'gray'
        colormap gray;
    case 'hsv'
        colormap hsv;
end