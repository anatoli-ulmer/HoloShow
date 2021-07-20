function data = image_bin(data, m)
% fuck this!
% muss gerade sein

if nargin<2
    m=1;
end

for i=1:m
    [N,M]=size(data);
    binarray1 = 1:2:N-1;
    binarray2 = 1:2:M-1;
    temp = data(binarray1,:)+data(binarray1+1,:);
    data = temp(:,binarray2)+temp(:,binarray2);
    data = data/4;
end