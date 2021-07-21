function save_holoShow(app, event)

foldername='Analysis';
if ~exist(foldername,'dir')
    mkdir(foldername)
end

try
    data.filename = app.handles.filenames{app.handles.fileIndex};
    data.h = app.handles.hologram;
    data.m = app.handles.mask;
    data.hardmask = app.handles.hardmask;

    data.roi = app.data.recon.roi;
    data.centroids = app.handles.centroids;
    data.phase = app.handles.phase;
    data.phaseOffset = app.handles.phaseOffset;

    data.spectrumHolo = app.handles.spectrumHolo;
    data.spectrumHoloDecon = app.handles.spectrumHoloDecon;
    data.spectrumRecon = app.handles.spectrumRecon;
    data.spectrumReconDecon = app.handles.spectrumReconDecon;
    data.noiseRect = app.handles.noiseRect;
    data.noiseSpec = app.handles.noiseSpec;
    data.noiseSpec2D = app.handles.noiseSpec2D;
    data.SNR2D = app.handles.SNR2D;
    
    data.clusterradius = app.handles.clusterradius;
    data.wiener = app.handles.wiener; 
    
    data.FRC.data = app.handles.FRC.data;
    data.FRC.twoSigma = app.handles.FRC.twoSigma;
    data.FRC.halfBit = app.handles.FRC.halfBit; %#ok<STRNU>    
catch ME
    warning(['Did not save! reason: ' ME.message])
end    

save(fullfile(foldername,[app.handles.currentFile(1:end-3),'mat']),'-struct','data')
