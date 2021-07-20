function reconScalebar(app, ax)

drawnow

nmPerPixel = app.handles.lambda*1e9/2/sin(atan(512*75e-6/app.handles.detDistance));

sarray = [10, 20, 50, 100, 200, 500, 1000];

% N = floor(ax.XLim(2));
N = floor(ax.Children(end).XData(2));
sc = max(sarray(sarray<N*nmPerPixel/2));

sbarL = sc/nmPerPixel;
% sbarW = sbarL/10;
sbarW = 1;

sbarPosition = [N-sbarL-2*sbarW, 3*sbarW, sbarL, sbarW];
stextPosition = sbarPosition(1:2) + [sbarL/2, sbarPosition(4)] ;
stextText = sprintf('%d nm', sc);

if isfield(ax.UserData, 'scalebar')
    ax.UserData.scalebar.Position = sbarPosition;
    ax.UserData.scalebarText.Position = stextPosition;
    ax.UserData.scalebarText.String = stextText;
else
    hold(ax, 'on');
    ax.UserData.scalebar = rectangle('Position', sbarPosition, ...
        'facecolor', 'k', 'parent', ax);
    ax.UserData.scalebarText = text(ax, stextPosition(1), stextPosition(2), stextText, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    %     title(ax, ['scalebar = ', num2str(sc), ' nm'])
    hold(ax, 'off');
end
