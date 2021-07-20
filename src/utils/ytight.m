function ytight(ax)

    % Set axis tight only on y-axes
    xl=xlim(ax); % retrieve auto y-limits
    axis tight   % set tight range
    xlim(ax,xl)  % restore y limits 
    
end
