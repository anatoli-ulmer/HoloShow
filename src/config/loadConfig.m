function loadConfig(app, event)

app.handles.experiment = app.config_popupmenu.Value;

fileID = fopen([app.handles.experiment, '.cfg']);
while ~feof(fileID)
    eval(char(fgetl(fileID)))
end
fclose(fileID);

app.wavelength_edit.Value = num2str(app.handles.lambda*1e9);
app.detDist_edit.Value = num2str(app.handles.detDistance);
app.load_mask_checkbox.Value = app.handles.load_mask);
app.cm_checkbox.Value = app.handles.do_cm);
app.min_edit.Value = num2str(app.handles.minScale);
app.max_edit.Value = num2str(app.handles.maxScale);
app.highpass_checkbox.Value = app.handles.HPfiltering);
app.lowpass_checkbox.Value = app.handles.LPfiltering);
app.highpass_edit.Value = num2str(app.handles.HPfrequency);
app.lowpass_edit.Value = num2str(app.handles.LPfrequency);
app.clusterradius_edit.Value = num2str(app.handles.clusterradius);
app.scattRatio_slider.Value = app.handles.scat_ratio);
app.scattRatio_edit.Value = num2str(app.handles.scat_ratio);
