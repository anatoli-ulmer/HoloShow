function load_config(app, event)

app.handles.experiment = app.config_popupmenu.Value;

fileID = fopen([app.handles.experiment, '.hcfg']);
while ~feof(fileID)
    eval(char(fgetl(fileID)))
end
fclose(fileID);

set(app.wavelength_edit, 'Value', num2str(app.handles.lambda*1e9));
set(app.detDist_edit, 'Value', num2str(app.handles.detDistance));
set(app.load_mask_checkbox, 'Value', app.handles.load_mask);
set(app.cm_checkbox, 'Value', app.handles.do_cm);
set(app.min_edit, 'Value', num2str(app.handles.minScale));
set(app.max_edit, 'Value', num2str(app.handles.maxScale));
set(app.highpass_checkbox, 'Value', app.handles.HPfiltering);
set(app.lowpass_checkbox, 'Value', app.handles.LPfiltering);
set(app.highpass_edit, 'Value', num2str(app.handles.HPfrequency));
set(app.lowpass_edit, 'Value', num2str(app.handles.LPfrequency));
set(app.clusterradius_edit, 'Value', num2str(app.handles.clusterradius));
set(app.scattRatio_slider, 'Value', app.handles.scat_ratio);
set(app.scattRatio_edit, 'Value', num2str(app.handles.scat_ratio));
