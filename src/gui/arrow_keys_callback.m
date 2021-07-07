function arrow_keys_callback(app, event)

switch event.Key
    case 'leftarrow'
        app.handles.fileIndex = app.handles.fileIndex-1;
        if app.handles.fileIndex < 1
            return
        end
    case 'rightarrow'
        app.handles.fileIndex = app.handles.fileIndex+1;
        if app.handles.fileIndex > size(app.handles.filenames,2)
            return
        end
    case 'return'
%         app.handles.fileIndex = get(app.filenames_listbox, 'Value');
        [~, app.handles.fileIndex] = ismember(app.filenames_listbox.Value, app.filenames_listbox.Items);
    otherwise
        return
end

% set(app.filenames_listbox, 'Value', app.handles.fileIndex)
app.filenames_listbox.Value = app.filenames_listbox.Items{app.handles.fileIndex};
select_hologram(app, event);
