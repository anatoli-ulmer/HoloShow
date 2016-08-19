function do_it_yourself(hObject, eventdata, handles, ...
    find_phase_pushbutton_Callback, ...
    center_pushbutton_Callback, ...
    powerSpec_pushbutton_Callback, ...
    find_decon_pushbutton_Callback, ...
    SNR_pushbutton_Callback)

set(handles.filenames_listbox, 'Value', handles.fileIndex);
try
    handles = select_hologram(hObject, eventdata, handles);
catch
    return
end
CCsize=70;
handles.centroids = find_CC(handles.recon);
nbrCCs = size(handles.centroids,1);
maxPhase = get(handles.phase_slider, 'Max');

for CC=1:1%size(handles.centroids,1)
    handles.rect(1) = round(handles.centroids(CC,1)-CCsize/2);
    handles.rect(2) = round(handles.centroids(CC,2)-CCsize/2);
    handles.rect(3) = CCsize;
    handles.rect(4) = CCsize;
    handles = show_recon(hObject, eventdata, handles);
    find_phase_pushbutton_Callback(hObject, eventdata, handles);
    center_pushbutton_Callback(hObject, eventdata, handles);
    center_pushbutton_Callback(hObject, eventdata, handles);
    powerSpec_pushbutton_Callback(hObject, eventdata, handles);
    SNR_pushbutton_Callback(hObject, eventdata, handles);
    find_decon_pushbutton_Callback(hObject, eventdata, handles);
    pause
    save_image_pushbutton_Callback(hObject, eventdata, handles);
end
