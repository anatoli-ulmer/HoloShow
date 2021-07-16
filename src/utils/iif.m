function out = iif(cond,a,b)
    % Inline if function returns a if cond is true and b otherwise.
    if cond
        out = a;
    else
        if exist('b', 'var')
            out = b;
        else
            out = [];
        end
    end
end
