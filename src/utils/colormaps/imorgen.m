function cm = imorgen
cm = colormap(morgenstemning);
cm = cm(end:-1:1,:);
% cm(1:50,:) = [];
% cm = [[1,1,1]; cm];