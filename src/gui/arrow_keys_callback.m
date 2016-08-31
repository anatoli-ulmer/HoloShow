function handles = arrow_keys_callback(hObject, eventdata, handles)

switch eventdata.Key
    case 'leftarrow'
        handles.fileIndex = handles.fileIndex-1;
        if handles.fileIndex < 1
            return
        end
    case 'rightarrow'
        handles.fileIndex = handles.fileIndex+1;
        if handles.fileIndex > size(handles.filenames,2)
            return
        end
    case 'return'
        handles.fileIndex = get(handles.filenames_listbox, 'Value');
    otherwise
        return
end

set(handles.filenames_listbox, 'Value', handles.fileIndex)
handles = select_hologram(hObject, eventdata, handles);