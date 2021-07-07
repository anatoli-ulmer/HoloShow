function data = str2num_fast(str, numCols)
% str2num_fast - faster alternative to str2num
    try
        % Fast code:
        str = char(str);
        str(:,end+1) = ' ';
        data = sscanf(str','%f');
        if nargin>1 && ~isempty(numCols)
            data = reshape(data,numCols,[])';
        end
    catch
        % This is much simpler but also much slower...
        data = str2num(str);
    end
end