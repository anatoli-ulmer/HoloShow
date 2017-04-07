function varargout = command_window(varargin)
% COMMAND_WINDOW MATLAB code for command_window.fig
%      COMMAND_WINDOW, by itself, creates a new COMMAND_WINDOW or raises the existing
%      singleton*.
%
%      H = COMMAND_WINDOW returns the handle to a new COMMAND_WINDOW or the handle to
%      the existing singleton*.
%
%      COMMAND_WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMMAND_WINDOW.M with the given input arguments.
%
%      COMMAND_WINDOW('Property','Value',...) creates a new COMMAND_WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before command_window_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to command_window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help command_window

% Last Modified by GUIDE v2.5 07-Apr-2017 16:25:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @command_window_OpeningFcn, ...
                   'gui_OutputFcn',  @command_window_OutputFcn, ...
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


% --- Executes just before command_window is made visible.
function command_window_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to command_window (see VARARGIN)

% Choose default command line output for command_window
handles.output = hObject;
% set(handles.cm_hist_edit, 'enable','inactive');
handles.cm_hist_text = {};
handles.ind = 1;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes command_window wait for user response (see UIRESUME)
% uiwait(handles.command_figure);


% --- Outputs from this function are returned to the command line.
function varargout = command_window_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function cm_edit_Callback(hObject, eventdata, handles)
holoShow_figure = findobj('Tag','holoShow');
holoShow_guidata = guidata(holoShow_figure);
cm = char(get(handles.cm_edit, 'String'));
cm = strrep(cm, 'handles', 'holoShow_guidata');
eval(cm);
guidata(holoShow_figure, holoShow_guidata);

handles.cm_hist_text{handles.ind} = handles.cm_edit.String;
handles.cm_hist_edit.String = sprintf('%s\n', handles.cm_hist_text{:});
handles.cm_edit.String = '';
handles.ind = handles.ind+1;
guidata(hObject, handles);


function cm_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
