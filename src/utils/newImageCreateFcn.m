function newImageCreateFcn(src, event)

    colorbar(src.Parent);
    src.Parent.YDir = 'normal';
    src.Parent.XGrid = 'off';
    src.Parent.YGrid = 'off';
    src.Parent.ZGrid = 'off';

end
