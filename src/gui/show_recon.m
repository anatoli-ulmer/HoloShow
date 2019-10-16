function handles_return = show_recon(hObject, eventdata, handles)

handles.reconI = imagesc(log(abs(handles.recon(...
    handles.rect(2):handles.rect(2)+handles.rect(4),...
    handles.rect(1):handles.rect(1)+handles.rect(3)))),...
    'parent', handles.reconAxes); 
set_colormap(handles.colormap, handles.reconAxes);
handles.reconColorbar = colorbar(handles.reconAxes);
axis(handles.reconAxes, 'image')
if get(handles.scale_checkbox, 'Value')
    caxis(handles.reconAxes, [handles.minScale, handles.maxScale]);
end

handles = refreshImage(hObject, eventdata, handles);

handles_return = handles;