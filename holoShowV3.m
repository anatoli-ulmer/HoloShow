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

% Last Modified by GUIDE v2.5 17-Aug-2016 18:01:41

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
handles.sourcepath = pwd;
addpath(genpath(handles.sourcepath));

handles.output = hObject;
handles.hologramFigure = figure('Name','hologram');
handles.reconstructionFigure = figure('Name','reconstruction');
handles.square = get(handles.square_checkbox, 'Value');
handles.logSwitch = get(handles.log_checkbox, 'Value');
handles.partSwitch = get(get(handles.part_buttongroup, 'SelectedObject'), 'String');
handles.image_correction = true;

load('config_holoShow.mat'); % To change standard values use 'src/config/create_config.m' to change config file
for fn = fieldnames(config_file)'
   handles.(fn{1}) = config_file.(fn{1});
end

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
[handles.filenames, handles.pathname] = uigetfile('*.dat;*.mat','select hologram files','E:\LCLS\data','MultiSelect','On'); % get list of files and path
set(handles.filenames_listbox, 'String', handles.filenames);
guidata(hObject, handles);


function filenames_listbox_Callback(hObject, eventdata, handles)


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
handles.fileIndex = handles.fileIndex+1;
if handles.fileIndex > size(handles.filenames,2)
    return
end
set(handles.filenames_listbox, 'Value', handles.fileIndex);
handles = select_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


function previous_pushbutton_Callback(hObject, eventdata, handles)
handles.fileIndex = handles.fileIndex-1;
if handles.fileIndex < 1
    return
end
set(handles.filenames_listbox, 'Value', handles.fileIndex);
handles = select_hologram(hObject, eventdata, handles);
guidata(hObject, handles);


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
refreshImage(hObject, eventdata, handles)
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
handles.phase = find_focus(handles.hologram.masked, handles.rect, -maxPhase, maxPhase, 100, true, true, get(handles.makeGIF_checkbox,'value'));
set(handles.phase_slider, 'Value', handles.phase);
set(handles.phase_edit, 'String', num2str(round(handles.phase)));
refreshImage(hObject, eventdata, handles);
guidata(hObject, handles);


function image_correction_checkbox_Callback(hObject, eventdata, handles)
handles.image_correction = get(handles.image_correction_checkbox, 'Value');
guidata(hObject, handles);


function colormap_buttongroup_SelectionChangedFcn(hObject, eventdata, handles)
handles.colormap = get(get(handles.colormap_buttongroup, 'SelectedObject'), 'String');
handles = show_recon(hObject, eventdata, handles);
guidata(hObject, handles);


function findCC_pushbutton_Callback(hObject, eventdata, handles)
handles.centroids = find_CC(handles.recon);
if isequal(handles.centroids,[0,0])
    msgbox('no cross correlations found!')
end
guidata(hObject, handles);


function focusCC_pushbutton_Callback(hObject, eventdata, handles)
fprintf('looking for cross correlations...')
handles.centroids = find_CC(handles.recon);
fprintf(' done!\n')
if isequal(handles.centroids,[0,0])
    return
end
maxPhase = get(handles.phase_slider, 'Max');
fprintf('looking for foci...')
find_foci(handles.hologram.masked, handles.centroids, -maxPhase, maxPhase, 200, handles.pathname, handles.currentFile, true, false);
fprintf(' done!\n')
guidata(hObject, handles);


function wholeRun_pushbutton_Callback(hObject, eventdata, handles)

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
    
    for i = 1:size(handles.filenames,2)
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
            find_foci(handles.hologram.masked, handles.centroids, -maxPhase, maxPhase, 200, handles.pathname, handles.currentFile, true, false);            
        catch
            fprintf('failed on %s !!!\n', handles.currentFile);
        end
    end
end
guidata(hObject, handles);


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
figure;
imagesc(real(handles.recon));
part_and_scale(handles.recon, handles.logSwitch, handles.partSwitch); colorbar;
caxis([handles.minScale, handles.maxScale]); set_colormap(handles.colormap); axis square;
handles.noiseRect = getrect(gca);
close(gcf);
handles.noiseRect = round(handles.noiseRect);
handles.square = get(handles.square_checkbox, 'Value');
if handles.square
    handles.noiseRect(3) = max([handles.noiseRect(3),handles.noiseRect(4)]);
    handles.noiseRect(4) = max([handles.noiseRect(3),handles.noiseRect(4)]);
end
noise = handles.recon(handles.noiseRect(2):handles.noiseRect(2)+handles.noiseRect(4),handles.noiseRect(1):handles.noiseRect(1)+handles.noiseRect(3));
noise = noise/length(noise);
Fnoise = fftshift(abs(fft2(noise,1024,1024)));
temp = rscan(Fnoise,'dispflag',false);
temp = temp(1:511);
figure(80); plot(1:511,log(temp(1:511))); title('noise');

handles.noiseSpec = temp.^2;
handles.noiseSpec2D = Fnoise;
guidata(hObject, handles);


function SNR_pushbutton_Callback(hObject, eventdata, handles)
recon = handles.recon(handles.rect(2):handles.rect(2)+handles.rect(4),handles.rect(1):handles.rect(1)+handles.rect(3));
Frecon = fftshift(abs(fft2(recon,1024,1024)/length(recon)));
temp = rscan(Frecon,'dispflag',false);
temp = temp(1:511).^2;
SNR = (temp(1:511)./handles.noiseSpec(1:511));
x=1:511;
% figure(80); plot(1:511,log(temp(1:511)),1:511,log(handles.noiseSpec(1:511))); legend('signal','noise'); grid on;
figure(81); semilogy(x,SNR,1:511,ones(1,511)*1,x,ones(1,511)*3); hold on;
legend('SNR', 'SNR=1', 'SNR=3')
xlim([0 511]); grid on;
ax=gca;
ax.XTick=0:50:500;
ax.XTickLabel=round((1.053e-9*0.735/75e-6/2*1e9)./(0:50:500));
xlabel('resolution in nm')

minFreq=20;
try
    diff=SNR(1+minFreq:end)-ones(1,511-minFreq);
    idx = find(diff < eps, 1)+minFreq;
    px1 = x(idx);
    py1 = SNR(idx);
    diff=SNR(1+minFreq:end)-ones(1,511-minFreq)*3;
    idx = find(diff < eps, 1)+minFreq;
    px3 = x(idx);
    py3 = SNR(idx);
    plot(px1, py1, 'ro', px3, py3, 'ro', 'MarkerSize', 10);
    title(sprintf('SNR -- \\delta_{SNR1} = %1.fnm, \\delta_{SNR3} = %1.fnm', (1.053e-9*0.735/75e-6/2*1e9)/px1,(1.053e-9*0.735/75e-6/2*1e9)/px3));
end
hold off;

handles.SNR2D=(Frecon./handles.noiseSpec2D).^2;

% temp = rscan(Frecon./handles.noiseSpec2D,'dispflag',false);
% handles.SNR2D=zeros(1024);
% for i=-512:511
%     for j=-512:511
%         if i^2+j^2==0 || round(sqrt(i^2+j^2))>511
%             handles.SNR2D(i+513,j+513)=0;
%         else
%             handles.SNR2D(i+513,j+513)=temp(round(sqrt(i^2+j^2)));
%         end
%     end
% end

% figure(82);
% maxInt=max(max(log10((Frecon./handles.noiseSpec2D).^2)));
% subplot(121); imagesc(log10((Frecon./handles.noiseSpec2D).^2),[0, maxInt]); axis square; colorbar;
% subplot(122); imagesc(log10((Frecon./handles.noiseSpec2D).^2)>0); axis square; colorbar;

[FRCout, twoSigma, halfBit] = FRC(recon(1:2*(floor(end/2)),1:2*(floor(end/2))),'realspace',true,'superpixelsize',2,'ringwidth',2);
figure(83);
plot(FRCout); hold on;
plot(twoSigma);
plot(halfBit);
plot(0.5*ones(1,length(halfBit)));
hold off;
grid on;
ax=gca;
xxx=ax.XTick;
ax.XTickLabel=round((1.053e-9*0.735/75e-6/2*1e9)./(xxx/max(xxx(:))*511));
title('Fourier Ring Correlation');
legend('FRC', '2\sigma criterion', '1/2 bit criterion', '0.5 criterion')

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

if get(handles.decon_checkbox,'value')
    handles.hologram.deconvoluted = cluster_deconvolution(handles.hologram.propagated, handles.mask,...
        handles.clusterradius, handles.reconSpec, handles.wiener);
    handles.recon = - ift2(handles.hologram.deconvoluted);
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
