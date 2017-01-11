function create_config(filename)
% Creates config file with standart parameter set used on startup of
% holoShow. Keep in mind to backup your old config-file as this overwrites
% the existing one if no other name is specified!

if nargin < 1
    filename = 'config_holoShow_new.mat';
end

[pathstr,~,~] = fileparts(mfilename('fullpath'));

config_file.lambda = 5e-9;
config_file.detDistance = 0.210;
config_file.load_mask = false;
config_file.do_CM = false;
config_file.minScale = -1;
config_file.maxScale = 1;
config_file.colormap = 'ms';
config_file.centroids = [0,0];
config_file.xcenter = 0;
config_file.ycenter = 0;
config_file.shift = 0;
config_file.slit = 0;
config_file.phase = 0;
config_file.phaseOffset = 0;
config_file.HPfiltering = true;
config_file.LPfiltering = false;
config_file.HPfrequency = 50;
config_file.LPfrequency = 300;
config_file.clusterradius = 30;
config_file.gpu = true;

save(fullfile(pathstr, filename), 'config_file');