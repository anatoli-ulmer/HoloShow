[X,Y] = meshgrid(1:1024,1:1024)./1024.*2.*pi;
exp(1i*(ycenter*Y+xcenter*X+phaseOffset))
.*exp(1i*(handles.ycenter*Y+handles.xcenter*X+handles.phaseOffset));