function create_config(filename)
% Creates config file with standart parameter set used on startup of
% holoShow. Keep in mind to backup your old config-file as this overwrites
% the existing one if no other name is specified!

if nargin < 1
    filename = 'config_holoShow_new.mat';
end

[pathstr,~,~] = fileparts(mfilename('fullpath'));

config_file.lambda = 5.3e-9;
config_file.detDistance = 0.220;
config_file.load_mask = false;
config_file.img_offset = 0;
config_file.slit = 0;
config_file.shift = 0;
config_file.xcenter = 0;
config_file.ycenter = 0;
config_file.adu_min = 10;
config_file.adu_max = 15000;
config_file.do_CM = false;
config_file.cm_thresh = 50;
config_file.minScale = -.1;
config_file.maxScale = .1;
config_file.colormap = 'ms';
config_file.centroids = [0,0];
config_file.phase = 0;
config_file.phaseOffset = 0;
config_file.HPfiltering = true;
config_file.LPfiltering = false;
config_file.HPfrequency = 50;
config_file.LPfrequency = 300;
config_file.clusterradius = 30;

config_file.img_offset = 0;
config_file.slit = 27;
config_file.shift = 3;
config_file.xcenter = 5;
config_file.ycenter = -40;
config_file.adu_min = 15;
config_file.adu_max = 15000;
config_file.do_CM = 1;
config_file.cm_thresh = 10;
config_file.cluster_material = 'Kr';
config_file.decon_profile = 'mie';
config_file.mie_precision = 50000;
config_file.scat_ratio = 5;
config_file.gpu = true;


save(fullfile(pathstr, filename), 'config_file');