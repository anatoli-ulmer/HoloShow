function outp = zeropadding(inp, dims)

if nargin < 2
    dims = [1024, 1024];
elseif size(dims,2) == 1
    dims = [dims, dims];
end

if dims(1)==size(inp,1) && dims(2)==size(inp,2)
    outp = inp;
    return
end

outp = zeros(dims(1), dims(2));
xx = round(dims(1)/2 - size(inp,1)/2);
yy = round(dims(2)/2 - size(inp,2)/2);

outp(xx: xx+size(inp,1)-1, yy: yy+size(inp,2)-1) = inp;
