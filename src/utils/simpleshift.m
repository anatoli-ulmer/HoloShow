function A = simpleshift(A, shifts)

rts = shifts(1);
cts = shifts(2);

A = circshift(A, [rts,cts]);
if rts>0
    A(1:rts,:) = 0;
elseif rts<0
    A(end+rts:end,:) = 0;
end
if cts>0
    A(:,1:cts) = 0;
elseif cts <0
    A(:,end+cts:end) = 0;
end

A(:,1:cts) = 0;