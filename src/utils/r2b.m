function cm = r2b
ncols = 256;

HSVstartR = [0, 100, 62]./[360,100,100];
HSVendR = [0, 6, 100]./[360,100,100];
HSVzero = [0, 0, 100]./[360,100,100];
HSVstartB = [220, 100, 62]./[360,100,100];
HSVendB = [220, 6, 100]./[360,100,100];

RGBstartR = hsv2rgb(HSVstartR);
RGBendR = hsv2rgb(HSVendR);
RGBzero = hsv2rgb(HSVzero);
RGBstartB = hsv2rgb(HSVstartB);
RGBendB = hsv2rgb(HSVendB);

RGBdiffR = RGBendR-RGBstartR;
RGBdiffB = RGBendB-RGBstartB;

cm = [];
for idc = linspace(0,1,ncols)
    cm = [cm; RGBstartR+RGBdiffR*idc]; %#ok<*AGROW>
end
cm = [cm; RGBzero];
for idc = linspace(0,1,ncols)
    cm = [cm; RGBendB-RGBdiffB*idc];
end
