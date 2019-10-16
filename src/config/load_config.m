function handles = load_config(handles)

content = cellstr(get(handles.config_popupmenu, 'String'));
experiment = content{get(handles.config_popupmenu, 'Value')};

fileID = fopen([experiment, '.hcfg']);
while ~feof(fileID)
    eval(char(fgetl(fileID)))
end
fclose(fileID);

set(handles.wavelength_edit, 'String', num2str(handles.lambda*1e9));
set(handles.detDist_edit, 'String', num2str(handles.detDistance));
set(handles.load_mask_checkbox, 'Value', handles.load_mask);
set(handles.cm_checkbox, 'Value', handles.do_cm);
set(handles.min_edit, 'String', num2str(handles.minScale));
set(handles.max_edit, 'String', num2str(handles.maxScale));
set(handles.highpass_checkbox, 'Value', handles.HPfiltering);
set(handles.lowpass_checkbox, 'Value', handles.LPfiltering);
set(handles.highpass_edit, 'String', num2str(handles.HPfrequency));
set(handles.lowpass_edit, 'String', num2str(handles.LPfrequency));
set(handles.clusterradius_edit, 'String', num2str(handles.clusterradius));
set(handles.scattRatio_slider, 'Value', handles.scat_ratio);
set(handles.scattRatio_edit, 'String', num2str(handles.scat_ratio));
