function arrow_keys_callback(hObject, eventdata, handles)
switch eventdata.Key
    case 'leftarrow'
        handles.fileIndex = handles.fileIndex-1;
        if handles.fileIndex < 1
            return
        end
        set(handles.filenames_listbox, 'Value', handles.fileIndex);
        handles = select_hologram(hObject, eventdata, handles);
        guidata(hObject, handles);
    case 'rightarrow'
        handles.fileIndex = handles.fileIndex+1;
        if handles.fileIndex > size(handles.filenames,2)
            return
        end
        set(handles.filenames_listbox, 'Value', handles.fileIndex);
        handles = select_hologram(hObject, eventdata, handles);
        guidata(hObject, handles);
end
