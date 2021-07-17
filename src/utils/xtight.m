function xtight(ax)
    
    % Set axis tight only on y-axes
    yl=ylim(ax); % retrieve auto y-limits
    axis tight   % set tight range
    ylim(ax,yl)  % restore y limits 
    
end
