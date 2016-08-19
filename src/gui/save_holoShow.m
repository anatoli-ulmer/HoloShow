function save_holoShow(handles)

foldername='Analysis';
if ~exist(foldername,'dir')
    mkdir(foldername)
end

try
    data.filename = handles.filenames{handles.fileIndex};
    data.h = handles.hologram;
    data.m = handles.mask;
    data.hardmask = handles.hardmask;

    data.rect = handles.rect;
    data.centroids = handles.centroids;
    data.phase = handles.phase;
    data.phaseOffset = handles.phaseOffset;

    data.reconSpec = handles.reconSpec;
    data.reconSpecDecon = handles.reconSpecDecon;
    data.reconcutSpec = handles.reconcutSpec;
    data.reconcutSpecDecon = handles.reconcutSpecDecon;
    data.noiseRect = handles.noiseRect;
    data.noiseSpec = handles.noiseSpec;
    data.noiseSpec2D = handles.noiseSpec2D;
    data.SNR2D = handles.SNR2D;
    
    data.clusterradius = handles.clusterradius;
    data.wiener = handles.wiener; 
    
    data.FRC.data = handles.FRC.data;
    data.FRC.twoSigma = handles.FRC.twoSigma;
    data.FRC.halfBit = handles.FRC.halfBit; %#ok<STRNU>    
catch ME
    warning(['Did not save! reason: ' ME.message])
end    

save(fullfile(foldername,[handles.currentFile(1:end-3),'mat']),'-struct','data')
