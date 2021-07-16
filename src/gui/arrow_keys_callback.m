function arrow_keys_callback(app, event)

switch event.Key
    case {'leftarrow','uparrow'}
        if app.handles.fileIndex > 0
            app.handles.fileIndex = app.handles.fileIndex-1;
        end
    case {'rightarrow','downarrow'}
        if app.handles.fileIndex < app.handles.nbr_images+1
            app.handles.fileIndex = app.handles.fileIndex+1;
        end
    otherwise
        return
end

app.filenames_listbox.Value = app.handles.fileIndex;
select_hologram(app, event);
