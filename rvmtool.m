function varargout = rvmtool(varargin)
% rvmtool is the graphical user interface to the tool
%
% Programmer: Phillip Shaw
% Version: 0.1 (28 November 2012)
%
% varargout = rvmtool(varargin)
%
% INPUT:
%	varargin are any input arguments
%
% OUTPUT:
%	varargout are any output arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RVMTOOL MATLAB code for rvmtool.fig
%      RVMTOOL, by itself, creates a new RVMTOOL or raises the existing
%      singleton*.
%
%      H = RVMTOOL returns the handle to a new RVMTOOL or the handle to
%      the existing singleton*.
%
%      RVMTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RVMTOOL.M with the given input arguments.
%
%      RVMTOOL('Property','Value',...) creates a new RVMTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rvmtool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rvmtool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rvmtool

% Last Modified by GUIDE v2.5 28-Nov-2012 19:00:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rvmtool_OpeningFcn, ...
                   'gui_OutputFcn',  @rvmtool_OutputFcn, ...
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


% --- Executes just before rvmtool is made visible.
function rvmtool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rvmtool (see VARARGIN)

% Choose default command line output for rvmtool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rvmtool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rvmtool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cmd_getFile.
function cmd_getFile_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_getFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.statusField,'String',''); %empty the status text box
FilterSet = {'*.*','All Files (*.*)'}; %define filter set 
[file,path] = uigetfile(FilterSet,'Browse for spreadsheet'); %get file
handles.filename = file; %set filename
set(handles.inputFile,'String',file); %write filename to input text field
guidata(hObject, handles); %update handles structure


% --- Executes on button press in cmd_runTool.
function cmd_runTool_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_runTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xls2db(handles.filename); %run db script
%write to status field
set(handles.statusField,'String','Successfully imported data.');
guidata(hObject,handles); %update handles structure
