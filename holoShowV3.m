function varargout = holoShowV3(varargin)
% HOLOSHOWV3 MATLAB code for holoShowV3.fig
%      HOLOSHOWV3, by itself, creates a new HOLOSHOWV3 or raises the existing
%      singleton*.
%
%      H = HOLOSHOWV3 returns the handle to a new HOLOSHOWV3 or the handle to
%      the existing singleton*.
%
%      HOLOSHOWV3('CALLBACK',hObject,eventData,handlesx,...) calls the local
%      function named CALLBACK in HOLOSHOWV3.M with the given input arguments.
%
%      HOLOSHOWV3('Property','Value',...) creates a new HOLOSHOWV3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before holoShowV3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to holoShowV3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".    
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help holoShowV3

% Last Modified by GUIDE v2.5 20-Jan-2017 19:13:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @holoShowV3_OpeningFcn, ...
    'gui_OutputFcn',  @holoShowV3_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function holoShowV3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to holoShowV3 (see VARARGIN)

% Choose default command line output for holoShowV3
[handles.sourcepath,~,~] = fileparts(mfilename('fullpath'));
addpath(genpath(handles.sourcepath));

handles.cxi_entryname = '/entry_1/image_1/data';
handles.cxi_identifier = '/entry_1/experiment_identifier';

handles.output = hObject;
handles.hologramFigure = figure('Name','hologram');
handles.reconstructionFigure = figure('Name','reconstruction');
handles.square = get(handles.square_checkbox, 'Value');
handles.logSwitch = get(handles.log_checkbox, 'Value');
handles.partSwitch = get(get(handles.part_buttongroup, 'SelectedObject'), 'String');
handles.image_correction = true;
handles.af_method = 'variance';

handles.IF_filtering = get(handles.intensity_filter_checkbox, 'Value');
handles.IF_value = str2double(get(handles.intensity_filter_edit, 'String'));

load('config_holoShow_LCLS2016.mat'); % To change standard values use 'src/config/create_config.m' to change config file
for fn = fieldnames(config_file)'
   handles.(fn{1}) = config_file.(fn{1});
end

set(handles.wavelength_edit, 'String', num2str(handles.lambda*1e9));
set(handles.detDist_edit, 'String', num2str(handles.detDistance));
set(handles.load_mask_checkbox, 'Value', handles.load_mask);
set(handles.cm_checkbox, 'Value', handles.do_CM);
set(handles.min_edit, 'String', num2str(handles.minScale));
set(handles.max_edit, 'String', num2str(handles.maxScale));
set(handles.highpass_checkbox, 'Value', handles.HPfiltering);
set(handles.lowpass_checkbox, 'Value', handles.LPfiltering);
set(handles.highpass_edit, 'String', num2str(handles.HPfrequency));
set(handles.lowpass_edit, 'String', num2str(handles.LPfrequency));
set(handles.clusterradius_edit, 'String', num2str(handles.clusterradius));

load('src/files/mask.mat');
handles.origmask = (~mask).*drawnMask;

set(groot,'DefaultFigureColormap',gray)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes holoShowV3 wait for user response (see UIRESUME)
% uiwait(handles.holoShowV3);


% --- Outputs from this function are returned to the command line.
function varargout = holoShowV3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function load_pushbutton_Callback(hObject, eventdata, handles)
set(handles.filenames_listbox, 'Value', 1); % set selection to first entry
[handles.filenames, handles.pathname] = uigetfile('*.dat;*.mat;*.h5;*.cxi','select hologram files','E:\LCLS\data','MultiSelect','On'); % get list of files and path

if iscell(handles.filenames)
    handles.first_file = handles.filenames{1};
else
    handles.first_file = handles.filenames;
end
[~,~,handles.ext] = fileparts(handles.first_file);

if strcmp(handles.ext, '.cxi')
    entrylist = h5read(fullfile(handles.pathname, handles.first_file), handles.cxi_identifier);
    set(handles.filenames_listbox, 'String', entrylist);
    handles.nbr_images = size(entrylist,1);
else
    set(handles.filenames_listbox, 'String', handles.filenames);
    handles.nbr_images = size(handles.filenames,2);
end
guidata(hObject, handles);


function filenames_listbox_Callback(hObject, eventdata, handles)
if strcmp(get(handles.holoShowV3,'SelectionType'),'open')
    handles.fileIndex = get(handles.filenames_listbox, 'Value'); % get index of selection
    handles = select_hologram(hObject, eventdata, handles); % GRAB HOLOGRAM
    guidata(hObject, handles);
end

function filenames_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function select_pushbutton_Callback(hObject, eventdata, handles)
handles.fileIndex = get(handles.filenames_listbox, 'Value'); % get index of selection
handles = select_hologram(hObject, eventdata, handles); % GRAB HOLOGRAM
guidata(hObject, handles);


function holoShowV3_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);
close(handles.reconstructionFigure);
close(handles.hologramFigure);


function chooseCC_pushbutton_Callback(hObject, eventdata, handles)
newrect = getrect(handles.reconAxes);
newrect = round(newrect);
handles.square = get(handles.square_checkbox, 'Value');
if handles.square
    newrect(3) = max([newrect(3),newrect(4)]);
    newrect(4) = max([newrect(3),newrect(4)]);
end
handles.rect(1:2) = handles.rect(1:2)+newrect(1:2)-1;
handles.rect(3) = min([1024-newrect(1), newrect(3)]);
handles.rect(4) = min([1024-newrect(2), newrect(4)]);
handles = show_recon(hObject, eventdata, handles);
guidata(hObject, handles);


function reset_pushbutton_Callback(hObject, eventdata, handles)
handles.rect(1) = 1;
handles.rect(2) = 1;
handles.rect(3) = size(handles.hologram.orig,1)-1;
handles.rect(4) = size(handles.hologram.orig,2)-1;
handles = show_recon(hObject, eventdata, handles);
guidata(hObject, handles);


function square_checkbox_Callback(hObject, eventdata, handles)


function phase_slider_Callback(hObject, eventdata, handles)
handles.phase = round(get(handles.phase_slider, 'Value'));
set(handles.phase_edit, 'String', num2str(handles.phase));
guidata(hObject, handles);


function phase_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function min_edit_Callback(hObject, eventdata, handles)
handles.minScale = str2double(get(handles.min_edit, 'String'));
if get(handles.scale_checkbox, 'Value')
    axes(handles.reconAxes);
    caxis([handles.minScale, handles.maxScale]);
end
guidata(hObject, handles);


function min_edit_CreateFcn(hObject, eventdata, handles) %#ok<*DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function max_edit_Callback(hObject, eventdata, handles) %#ok<*INUSL>
handles.maxScale = str2double(get(handles.max_edit, 'String'));
if get(handles.scale_checkbox, 'Value')
    axes(handles.reconAxes);
    caxis([handles.minScale, handles.maxScale]);
end
guidata(hObject, handles);


function max_edit_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function scale_checkbox_Callback(hObject, eventdata, handles)
axes(handles.reconAxes);
if get(handles.scale_checkbox, 'Value')
    caxis manual;
    handles.minScale = str2double(get(handles.min_edit, 'String'));
    handles.maxScale = str2double(get(handles.max_edit, 'String'));
    caxis([handles.minScale, handles.maxScale]);
else
    caxis auto;
end
guidata(hObject, handles);


function next_pushbutton_Callback(hObject, eventdata, handles)
% while true
    handles.fileIndex = handles.fileIndex+1;
    if handles.fileIndex > handles.nbr_images
        return
    end

    set(handles.filenames_listbox, 'Value', handles.fileIndex);
    handles = select_hologram(hObject, eventdata, handles);

    %%%%%%%%%%%%%%% TEMPORAL! REMOVE THIS IF YOU FIND IT!!! %%%%%%%%%%%%%%%%%%%

%     polmat = polar_matrix(image_bin(handles.hologram.orig.*handles.hardmask,2));
%     figure(343);
%     subplot(211); imagesc(log10(abs(polmat(:,15:128))), [0, 4.2]); colormap morgenstemning
%     angularsum = sum(abs(polmat(:,15:128)'));
%     angularsum(140:210) = [];
%     angularsum(45:80) = [];
%     asymmetryVal = 1e-8*var(angularsum);
%     subplot(212); plot(angularsum); title(num2str(asymmetryVal))
%     if asymmetryVal > 0.5
%         break
%     end
%     'bounce'
% end
guidata(hObject, handles);


function previous_pushbutton_Callback(hObject, eventdata, handles)
handles.fileIndex = handles.fileIndex-1;
if handles.fileIndex < 1
    return
end
set(handles.filenames_listbox, 'Value', handles.fileIndex);
handles = select_hologram(hObject, eventdata, handles);
guidata(handles.output, handles);


function range_edit_Callback(hObject, eventdata, handles)
newRange = str2double(get(handles.range_edit, 'String'));
set(handles.phase_slider, 'Max', newRange);
set(handles.phase_slider, 'Min', -newRange);


function range_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function phase_edit_Callback(hObject, eventdata, handles)
handles.phase = str2double(get(handles.phase_edit, 'String'));
set(handles.phase_slider, 'Value', handles.phase);
handles = refreshImage(hObject, eventdata, handles);
guidata(hObject, handles);


function phase_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function log_checkbox_Callback(hObject, eventdata, handles)
handles.logSwitch = get(handles.log_checkbox, 'Value');
handles = show_recon(hObject, eventdata, handles);
guidata(hObject, handles);


function part_buttongroup_SelectionChangedFcn(hObject, eventdata, handles)
handles.partSwitch = get(get(handles.part_buttongroup, 'SelectedObject'), 'String');
handles = show_recon(hObject, eventdata, handles);
guidata(hObject, handles);


function find_phase_pushbutton_Callback(hObject, eventdata, handles)
maxPhase = get(handles.phase_slider, 'Max');
handles.phase = find_focus(handles.hologram.masked, handles.lambda, handles.detDistance, handles.rect, -maxPhase, maxPhase, 100, handles.af_method, true, handles.gpu, get(handles.makeGIF_checkbox,'value'), 1);
set(handles.phase_slider, 'Value', handles.phase);
set(handles.phase_edit, 'String', num2str(round(handles.phase)));
handles = refreshImage(hObject, eventdata, handles);
guidata(hObject, handles);


function image_correction_checkbox_Callback(hObject, eventdata, handles)
handles.image_correction = get(handles.image_correction_checkbox, 'Value');
guidata(hObject, handles);


function colormap_buttongroup_SelectionChangedFcn(hObject, eventdata, handles)
handles.colormap = get(get(handles.colormap_buttongroup, 'SelectedObject'), 'String');
handles = show_recon(hObject, eventdata, handles);
guidata(hObject, handles);


function findCC_pushbutton_Callback(hObject, eventdata, handles)
% rec = dlmread('C:\Users\Toli\Downloads\189004407 (1).dat')';
handles.centroids = find_CC(handles.hologram.masked, 'show_img', true, 'min_dist', 100, 'int_thresh', 5, 'r_ignored', 75, 'crop_factor', handles.crop_factor);
if isequal(handles.centroids,[0,0])
    msgbox('no cross correlations found!')
end
guidata(hObject, handles);


function focusCC_pushbutton_Callback(hObject, eventdata, handles)
fprintf('looking for cross correlations...')
handles.centroids = find_CC(handles.hologram.masked, 'show_img', true, 'min_dist', 100, 'int_thresh', 5, 'r_ignored', 75, 'crop_factor', handles.crop_factor);
fprintf(' done!\n')
if isequal(handles.centroids,[0,0])
    return
end
maxPhase = get(handles.phase_slider, 'Max');
fprintf('looking for foci...')

handles.foci = find_foci(handles.hologram.masked, handles.lambda, handles.detDistance, handles.centroids, ...
    'z_start', -maxPhase, 'z_end', maxPhase, 'steps', 20, 'use_gpu', true, 'show_results', true, 'crop_factor', handles.crop_factor);
fprintf(' done!\n')
guidata(hObject, handles);


function wholeRun_pushbutton_Callback(hObject, eventdata, handles)
while true
    if get(handles.abort_pushbutton, 'UserData')
        set(handles.abort_pushbutton, 'UserData', false)
        break
    end
    handles = select_hologram(hObject, eventdata, handles);
%     handles.centroids = find_CC(handles.recon, 'show_img', true, 'min_dist', 100, 'int_thresh', 5, 'r_ignored', 75);
    focusCC_pushbutton_Callback(hObject, eventdata, handles);
    handles.fileIndex = handles.fileIndex+1;
    if handles.fileIndex > handles.nbr_images
        return
    end
    set(handles.filenames_listbox, 'Value', handles.fileIndex);
end


function center_pushbutton_Callback(hObject, eventdata, handles)
[columnsToShift, rowsToshift, handles.phaseOffset] = find_center(handles.hologram.masked, handles.phase, handles.rect);
handles.xcenter = handles.xcenter + columnsToShift;
handles.ycenter = handles.ycenter + rowsToshift;
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function shifts_pushbutton_Callback(hObject, eventdata, handles)
[shift, slit, handles.phaseOffset] = find_shift(handles.hologram.masked, handles.phase, handles.rect);
handles.shift = handles.shift + shift;
handles.slit = handles.slit + slit;
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function noise_pushbutton_Callback(hObject, eventdata, handles)
[handles.noiseSpec, handles.noiseSpec2D] = get_noise_spectrum(handles);
guidata(hObject, handles);


function SNR_pushbutton_Callback(hObject, eventdata, handles)
recon = handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3));
Frecon = fftshift(abs(fft2(recon,1024,1024)/length(recon)));
temp = rscan(Frecon,'dispflag',false);
x = 1:511;
Q = handles.lambda*handles.detDistance/75e-6/2*1e9;
temp = temp(x).^2;
[handles.noiseSpec, handles.noiseSpec2D] = get_noise_spectrum(handles);
SNR = (temp(x)./handles.noiseSpec(x));
% figure(80); plot(x,log(temp(x)),x,log(handles.noiseSpec(x))); legend('signal','noise'); grid on;
figure(81); subplot (211); semilogy(x, SNR, x, ones(1,511)*1, x, ones(1,511)*5); hold on;
legend('SNR', 'SNR=1', 'SNR=5')
xlim([0 511]); grid on;
ax=gca;
ax.XTick=0:50:500;
ax.XTickLabel=round(Q./(0:50:500));
xlabel('resolution in nm')

minFreq=20;
try
    diff=SNR(1+minFreq:end)-ones(1,511-minFreq)*5;
    idx = find(diff < eps, 1)+minFreq;
    px3 = x(idx);
    py3 = SNR(idx);
    plot(px3, py3, 'ro', 'MarkerSize', 10);
    title(sprintf('SNR = 5 at ~ %1.fnm', Q/px3));
end
hold off;

handles.SNR2D=(Frecon./handles.noiseSpec2D).^2;

superpixelsize = 2;
[FRCout, twoSigma, halfBit] = FRC(recon(1:2*(floor(end/2)),1:2*(floor(end/2))),'realspace',true,'superpixelsize',superpixelsize,'ringwidth',2);
x = 1:length(FRCout);
subplot (212); plot(x, FRCout, x, twoSigma, x, halfBit, x, 0.5*ones(1,length(halfBit)));
grid on;
ax=gca;
xticks=ax.XTick;
ax.XTickLabel=round(Q*superpixelsize./(xticks/max(xticks(:))*511));
title('Fourier Ring Correlation');
legend('FRC', '2\sigma criterion', '1/2 bit criterion', '0.5 criterion')
try
    minFreq=3; hold on;
    diff=FRCout(1+minFreq:end)-ones(1,length(FRCout)-minFreq)*0.5;
    idx = find(diff < eps, 1)+minFreq-1;
    px3 = x(idx);
    py3 = FRCout(idx);
    plot(px3, py3, 'ro', 'MarkerSize', 10);
    title(sprintf('FRC resolution ~ %1.fnm', Q*superpixelsize/(px3/max(xticks(:))*511)));
    xlabel('resolution in nm')
    ylim([0, 1.05])
end
hold off;

handles.FRC.data = FRCout;
handles.FRC.twoSigma = twoSigma;
handles.FRC.halfBit = halfBit;

guidata(hObject, handles);


function powerSpec_pushbutton_Callback(hObject, eventdata, handles)
reconcut = handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3));
Freconcut = fftshift(abs(fft2(reconcut,1024,1024)));
reconcutSpec = rscan(Freconcut,'dispflag',false);
reconcutSpec = reconcutSpec(1:511).^2;
recon = handles.recon;
Frecon = fftshift(abs(fft2(recon,1024,1024)));
reconSpec = rscan(Frecon,'dispflag',false);
reconSpec = reconSpec(1:511).^2;

% rat=reconSpec./reconcutSpec;

figure(85);
subplot(121); semilogy(50:length(reconSpec),reconSpec(50:end)); title('power spectrum full image')
subplot(122); semilogy(50:length(reconcutSpec),reconcutSpec(50:end)); title('power spectrum chosen CC')

if get(handles.decon_checkbox, 'Value')
    handles.reconSpecDecon = reconSpec;
    handles.reconcutSpecDecon = reconcutSpec;
else
    handles.reconSpec = reconSpec;
    handles.reconcutSpec = reconcutSpec;
end
guidata(hObject, handles);


function goodShot_pushbutton_Callback(hObject, eventdata, handles)
shotlist=get(handles.filenames_listbox, 'String');
shotname=char(shotlist(get(handles.filenames_listbox, 'Value'))) %#ok<NOPRT>
foldername=shotname(1:5);
anapath = fullfile(handles.sourcepath, 'analysis','good_shots');
if ~exist(anapath, 'dir')
    mkdir(anapath)
end
fileID=fopen(fullfile(anapath,[foldername,'.txt']),'a');
fprintf(fileID,'%s\n',shotname);
fclose(fileID);

picpath = 'E:\LCLS\data\+mimi\pics';
print(figure(1), fullfile(picpath, [shotname(1:end-4), '_scatt.png']), '-dpng');
print(figure(2), fullfile(picpath, [shotname(1:end-4), '_recon.png']), '-dpng');
print(figure(81), fullfile(picpath, [shotname(1:end-4), '_resolution.png']), '-dpng');
print(figure(23446), fullfile(picpath, [shotname(1:end-4), '_decon.png']), '-dpng');




function lowpass_edit_Callback(hObject, eventdata, handles)
handles.LPfiltering = get(handles.lowpass_checkbox,'value');
handles.LPfrequency = round(str2double(get(handles.lowpass_edit,'string')));
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);

function lowpass_checkbox_Callback(hObject, eventdata, handles)
handles.LPfiltering = get(handles.lowpass_checkbox,'value');
handles.LPfrequency = round(str2double(get(handles.lowpass_edit,'string')));
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function highpass_edit_Callback(hObject, eventdata, handles)
handles.HPfiltering = get(handles.highpass_checkbox,'value');
handles.HPfrequency = round(str2double(get(handles.highpass_edit,'string')));
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function highpass_checkbox_Callback(hObject, eventdata, handles)
handles.HPfiltering = get(handles.highpass_checkbox,'value');
handles.HPfrequency = round(str2double(get(handles.highpass_edit,'string')));
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function highpass_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lowpass_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function knife_edge_pushbutton_Callback(hObject, eventdata, handles)
axes(handles.reconAxes);
[xx,yy,handles.profile] = improfile;
try
    delete(handles.profileLine);
end
handles.profileLine = line([xx(1),xx(end)],[yy(1),yy(end)],'Color','r','LineWidth',2);

figure(10);
plot(handles.profile);
guidata(hObject, handles);

function makeGIF_checkbox_Callback(hObject, eventdata, handles)


function decon_checkbox_Callback(hObject, eventdata, handles)
fprintf('deconvoluting ...');
handles.hologram.propagated = propagate(abs(handles.hologram.masked), handles.phase, handles.lambda, handles.detDistance);
handles.hologram.propagated = handles.hologram.propagated.*exp(1i*handles.phaseOffset);

if isfield(handles,'SNR2D')
    handles.wiener=1./handles.SNR2D;
else
    handles.wiener=1;
end

if ~isfield(handles,'reconSpec')
    handles.reconSpec=1;
end

handles.wiener=90^2;
% handles.wiener=1e5;

if get(handles.decon_checkbox,'value')
    handles.hologram.deconvoluted = cluster_deconvolution(handles.hologram.propagated, handles.mask,...
        handles.clusterradius, handles.reconSpec, handles.wiener, handles.lambda, handles.detDistance);
    handles.recon = ift2(handles.hologram.deconvoluted);
else
    handles.recon = ift2(handles.hologram.propagated);
end

figure(23446);

imagesc(part_and_scale(handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3)),...
    handles.logSwitch, handles.partSwitch));
axis square;
title(num2str(handles.clusterradius));

fprintf('done! \n')
guidata(hObject, handles);


function clusterradius_edit_Callback(hObject, eventdata, handles)
handles.clusterradius=str2double(strrep(get(handles.clusterradius_edit,'String'),',','.'));
fprintf('Cluster radius changed to %.1f nm \n', handles.clusterradius)
guidata(hObject, handles);
decon_checkbox_Callback(hObject, eventdata, handles)


function clusterradius_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function find_decon_pushbutton_Callback(hObject, eventdata, handles)
fprintf('looking for cluster radius ...');
handles.hologram.propagated = propagate(abs(handles.hologram.masked), handles.phase, handles.lambda, handles.detDistance);
handles.hologram.propagated = handles.hologram.propagated.*exp(1i*handles.phaseOffset);

% if isfield(handles,'SNR2D')
%     wiener=1./handles.SNR2D;
% else
%     wiener=1;
% end

handles.wiener=85^2;
handles.clusterradius = find_decon(handles);
set(handles.clusterradius_edit, 'String', num2str(handles.clusterradius));
decon_checkbox_Callback(hObject, eventdata, handles);

fprintf('done! \n')
guidata(hObject, handles);


function cm_checkbox_Callback(hObject, eventdata, handles)
handles.do_CM = get(handles.cm_checkbox, 'Value');
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function load_mask_checkbox_Callback(hObject, eventdata, handles)
handles.load_mask = get(handles.load_mask_checkbox, 'Value');
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function holoShowV3_KeyPressFcn(hObject, eventdata, handles)
handles = arrow_keys_callback(hObject, eventdata, handles);
figure(hObject);
guidata(hObject, handles);


function filenames_listbox_KeyPressFcn(hObject, eventdata, handles)
handles = arrow_keys_callback(hObject, eventdata, handles);
figure(handles.holoShowV3);
guidata(hObject, handles);

function wavelength_edit_Callback(hObject, eventdata, handles)
handles.lambda = str2double(get(handles.wavelength_edit, 'String'))*1e-9;
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function wavelength_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wavelength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function detDist_edit_Callback(hObject, eventdata, handles)
handles.detDistance = str2double(get(handles.detDist_edit, 'String'));
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function detDist_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detDist_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function autofocus_popupmenu_Callback(hObject, eventdata, handles)
content = cellstr(get(handles.autofocus_popupmenu, 'String'));
handles.af_method = content{get(handles.autofocus_popupmenu, 'Value')};
guidata(hObject, handles);

function autofocus_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autofocus_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function save_handles_pushbutton_Callback(hObject, eventdata, handles)
shotlist=get(handles.filenames_listbox, 'String');
shotname=char(shotlist(get(handles.filenames_listbox, 'Value'))) %#ok<NOPRT>
% foldername=shotname(1:5);
% anapath = fullfile(handles.sourcepath, 'analysis','good_shots');
% if ~exist(anapath, 'dir')
%     mkdir(anapath)
% end
% fileID=fopen(fullfile(anapath,[foldername,'.txt']),'a');
% fprintf(fileID,'%s\n',shotname);
% fclose(fileID);

anapath = fullfile(handles.sourcepath, 'analysis','interesting');
if ~exist(anapath, 'dir')
    mkdir(anapath)
end

% picpath = uigetdir
% print(figure(1), fullfile(picpath, [shotname(1:end-4), '_scatt.png']), '-dpng');
[filename, pathname] = uiputfile('*.mat','Save handles as',fullfile(anapath, [shotname(1:end-4), '_handles.mat']));
save(fullfile(pathname, filename), 'handles');

function choose_runs_pushbutton_Callback(hObject, eventdata, handles)
handles.runfolders = uipickfiles;% pick run folders


for run=1:length(handles.runfolders)
    try
        handles.pathname = handles.runfolders{run};
        filelist = ls(handles.pathname);
        handles.filenames=[];
        for i=3:size(filelist,1)
            handles.filenames{i}=strrep(filelist(i,:),' ','');
        end
        
        set(handles.filenames_listbox, 'String', handles.filenames);
    catch
        continue
    end
    
    for i = 1:handles.nbr_images
        try
            handles.fileIndex = i;
            set(handles.filenames_listbox, 'Value', handles.fileIndex);
            try
                handles = select_hologram(hObject, eventdata, handles);
            catch
                continue
            end
            handles.centroids = find_CC(handles.recon);
            if size(handles.centroids,1)==1
                continue
            end
            maxPhase = get(handles.phase_slider, 'Max');
            handles.foci = find_foci(handles.hologram.masked, handles.lambda, handles.detDistance, handles.centroids, ...
    'z_start', -maxPhase, 'z_end', maxPhase, 'steps', 20, 'use_gpu', true, 'show_results', true, 'crop_factor', handles.crop_factor);           
        catch
            fprintf('failed on %s !!!\n', handles.currentFile);
        end
    end
end
guidata(hObject, handles);


function abort_pushbutton_Callback(hObject, eventdata, handles)
set(handles.abort_pushbutton, 'UserData', true);
guidata(hObject, handles);


function intensity_filter_edit_Callback(hObject, eventdata, handles)
handles.IF_filtering = get(handles.intensity_filter_checkbox, 'Value');
handles.IF_value = str2double(get(handles.intensity_filter_edit, 'String'));
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function intensity_filter_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function intensity_filter_checkbox_Callback(hObject, eventdata, handles)
handles.IF_value = str2double(get(handles.intensity_filter_edit, 'String'));
handles.IF_filtering = get(handles.intensity_filter_checkbox, 'Value');
handles = refresh_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function crop_edit_Callback(hObject, eventdata, handles)
handles.crop_image = get(handles.crop_checkbox, 'Value');
crp_fct = round(str2double(get(handles.crop_edit, 'String')));
if crp_fct > 1 && handles.crop_image
    handles.crop_factor = crp_fct;
else
    handles.crop_factor = 1;
end
guidata(hObject, handles);


function crop_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function crop_checkbox_Callback(hObject, eventdata, handles)
handles.crop_image = get(handles.crop_checkbox, 'Value');
crp_fct = round(str2double(get(handles.crop_edit, 'String')));
if crp_fct > 1 && handles.crop_image
    handles.crop_factor = crp_fct;
else
    handles.crop_factor = 1;
end
guidata(hObject, handles);