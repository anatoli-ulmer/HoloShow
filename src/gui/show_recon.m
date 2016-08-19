function handles_return = show_recon(hObject, eventdata, handles)
axes(handles.reconAxes);
handles.reconI = imagesc(log(abs(handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3))))); set_colormap(handles.colormap); colorbar;

if get(handles.scale_checkbox, 'Value')
    axes(handles.reconAxes);
    caxis([handles.minScale, handles.maxScale]);
end
if handles.square
    axis square
else
    axis tight
end
if get(handles.scale_checkbox, 'Value')
    axes(handles.reconAxes);
    caxis([handles.minScale, handles.maxScale]);
end

handles = refreshImage(hObject, eventdata, handles);

handles_return = handles;