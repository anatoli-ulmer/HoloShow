function do_it_yourself(app, ...
    find_phase_pushbutton_Callback, ...
    center_pushbutton_Callback, ...
    powerSpec_pushbutton_Callback, ...
    find_decon_pushbutton_Callback, ...
    SNR_pushbutton_Callback)

set(app.handles.filenames_listbox, 'Value', app.handles.fileIndex);
try
    app.handles = select_hologram(app, event;
catch
    return
end
CCsize=70;
app.handles.centroids = find_CC(app.handles.recon);
nbrCCs = size(app.handles.centroids,1);
maxPhase = get(app.handles.phase_slider, 'Max');

for CC=1:1%size(app.handles.centroids,1)
    app.handles.rect(1) = round(app.handles.centroids(CC,1)-CCsize/2);
    app.handles.rect(2) = round(app.handles.centroids(CC,2)-CCsize/2);
    app.handles.rect(3) = CCsize;
    app.handles.rect(4) = CCsize;
    app.handles = show_recon(app, event);
    find_phase_pushbutton_Callback(app, event);
    center_pushbutton_Callback(app, event);
    center_pushbutton_Callback(app, event);
    powerSpec_pushbutton_Callback(app, event);
    SNR_pushbutton_Callback(app, event);
    find_decon_pushbutton_Callback(app, event);
    pause
    save_image_pushbutton_Callback(app, event);
end
