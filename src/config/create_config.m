function create_config(filename)
% Creates config file with standart parameter set used on startup of
% holoShow. Keep in mind to backup your old config-file as this overwrites
% the existing one if no other name is specified!

if nargin < 1
    filename = 'config_holoShow.mat';
end

config_file.lambda = 1.55e-9;
config_file.detDistance = 0.735;
config_file.origmask = dlmread('mask.dat');
config_file.origmask = config_file.origmask(1:1024,1:1024);
config_file.drawnMask = dlmread('drawnMask.dat');
config_file.minScale = -2;
config_file.maxScale = 2;
config_file.colormap = 'fire';
config_file.centroids = [0,0];
config_file.xcenter = 0;
config_file.ycenter = 0;
config_file.shift = 0;
config_file.slit = -2;
config_file.phase = 0;
config_file.phaseOffset = 0;
config_file.HPfiltering = false;
config_file.LPfiltering = false;
config_file.HPfrequency = 60;
config_file.LPfrequency = 332;
config_file.clusterradius = 37;

[pathstr,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(pathstr, filename), 'config_file');