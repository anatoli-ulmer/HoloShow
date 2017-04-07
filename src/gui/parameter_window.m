function varargout = parameter_window(varargin)
% PARAMETER_WINDOW MATLAB code for parameter_window.fig
%      PARAMETER_WINDOW, by itself, creates a new PARAMETER_WINDOW or raises the existing
%      singleton*.
%
%      H = PARAMETER_WINDOW returns the handle to a new PARAMETER_WINDOW or the handle to
%      the existing singleton*.
%
%      PARAMETER_WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMETER_WINDOW.M with the given input arguments.
%
%      PARAMETER_WINDOW('Property','Value',...) creates a new PARAMETER_WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before parameter_window_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to parameter_window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help parameter_window

% Last Modified by GUIDE v2.5 13-Mar-2017 18:33:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @parameter_window_OpeningFcn, ...
                   'gui_OutputFcn',  @parameter_window_OutputFcn, ...
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


% --- Executes just before parameter_window is made visible.
function parameter_window_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to parameter_window (see VARARGIN)

% Choose default command line output for parameter_window
handles.output = hObject;
holoShow_figure = findobj('Tag','holoShow');
holoShow_guidata = guidata(holoShow_figure);
handles.parameter = {...
    'img_offset', holoShow_guidata.img_offset;...%1
    'add_slit', holoShow_guidata.add_slit;...%2
    'add_shift', holoShow_guidata.add_shift;...%3
    'xcenter', holoShow_guidata.xcenter;...%4
    'ycenter', holoShow_guidata.ycenter;...%5
    'adu_min', holoShow_guidata.adu_min;...%6
    'adu_max', holoShow_guidata.adu_max;...%7
    'do_cm', holoShow_guidata.do_cm;...%8
    'cm_thresh', holoShow_guidata.cm_thresh;...%9
    'cluster_material', holoShow_guidata.cluster_material;...
    'decon_profile', holoShow_guidata.decon_profile;...
    'mie_precision', holoShow_guidata.mie_precision;...
    'scat_ratio', holoShow_guidata.scat_ratio;...
    'gpu', holoShow_guidata.gpu;...
    };

set(handles.parameter_uitable, 'data', handles.parameter);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes parameter_window wait for user response (see UIRESUME)
% uiwait(handles.parameter_figure);


function varargout = parameter_window_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes when entered data in editable cell(s) in parameter_uitable.
function parameter_uitable_CellEditCallback(hObject, eventdata, handles)
td = get(handles.parameter_uitable, 'data');
holoShow_figure = findobj('Tag','holoShow');
holoShow_guidata = guidata(holoShow_figure);
% 
% holoShow_guidata.img_offset = td{1,2};
% holoShow_guidata.add_slit = td{2,2};
% holoShow_guidata.add_shift = td{3,2};
% holoShow_guidata.xcenter = td{4,2};
% holoShow_guidata.ycenter = td{5,2};
% holoShow_guidata.adu_min = td{6,2};
% holoShow_guidata.adu_max = td{7,2};
% holoShow_guidata.do_cm = td{8,2};
% holoShow_guidata.cm_thresh = td{9,2};
% 
% holoShow_guidata.cluster_material = td{10,2};
% holoShow_guidata.decon_profile = td{11,2};
% holoShow_guidata.mie_precision = td{12,2};
% holoShow_guidata.scat_ratio = td{13,2};
% holoShow_guidata.gpu = td{14,2};

for i=1:size(td,1)
    if strcmp(td{i,1},'')
        continue
    end
%     disp(td(i,2))
%     [td{i,1}, '=', td{i,2}]
% ['holoShow_guidata.', td{i,1}, ' = ', num2str(td{i,2}), ';']
    key = td{i,1};
    arg = num2str(td{i,2});
    if ischar(td{i,2})
        eval(['holoShow_guidata.', key, ' = ''', arg,''';'])
    else
        eval(['holoShow_guidata.', key, ' = ', arg, ';'])
    end
end    

holoShow_guidata.parameter = td;
holoShow_guidata = refresh_hologram(holoShow_figure, eventdata, holoShow_guidata);
guidata(holoShow_figure, holoShow_guidata);
