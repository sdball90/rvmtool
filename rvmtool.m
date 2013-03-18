function varargout = rvmtool(varargin)
%--------------------------------------------------------------------------
% rvmtool
%
% This is the graphical user interface code that allows the 
% user to control the associated program files of the tool,
% allowing the user to import the data from the spreadsheet and
% run the code that will plot the found relationships.
%
% HISTORY:
% 28 November 2012  Phillip Shaw       Original Code
%  7 February 2013  Zachary Kaberlein  Added more options to GUI
% 25 February 2013  Dennis Magee       Edit to FilterSet
% 11 March    2013  Phillip Shaw       Reiterate GUI control preference
% 17 March    2013  Dennis Magee       Fixed run tool bug with no file in saved state
%
% INPUTS:
% varargin are any input arguments
%
% OUTPUTS:
% varargout are any output arguments
%
% USAGE:
% rvmtool
% 
% CALLED MODULES:
% xls2db
% rfind
% plotr
%
% DESIGN:
%   initialize GUI
%   disable RUNTOOL button
%   disable RADIO buttons, SPECIFIC text field, COLUMN_NAME dropdown
%   IF prev exists, LOAD STATE
%   ELSEIF user selects spreadsheet
%       enable RUNTOOL button
%   IF user presses RUNTOOL button
%       import spreadsheet into database
%       find relationships
%       plot relationships in new figures
%   END
%   
% TODO:
%   -include radio button states, column names(?), specific text in save 
%   function. (DONE, except saving specific test requires handles to get
%   set)
%   -implement load of above (DONE)
%   -double check order and logic of init and flow steps (DONE, unless
%   fault in my logic, DOUBLE CHECK)
%   -FIX: when closing GUI without doing anything, PATH_TO_FILE string
%       gets saved as file, INVALID (NOT DONE)
% 
%--------------------------------------------------------------------------
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

% Last Modified by GUIDE v2.5 10-Feb-2013 13:08:10

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
% disable the runTool button
set(handles.cmd_runTool,'Enable','off');

%Set specific text field and listbox to disabled
set(handles.specificTextfield,'Enable','off');
set(handles.columnNamePopup,'Enable','off');
set(handles.generalRadiobutton, 'Enable', 'off');
set(handles.specificRadiobutton,'Enable','off');

% load the prev state of GUI
loadState(hObject, handles);

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

FilterSet = {'*.ods;*.xls;*.xlsx','All Spreadsheets (*.ods,*.xls*)';...
             '*.xlsx','Excel Workbook (*.xlsx)';...
             '*.xls','Excel 97-2003 Workbook (*.xls)';...
             '*.ods','OpenDocument Spreadsheet'}; %define filter set 

[file,path] = uigetfile(FilterSet,'Browse for spreadsheet'); %get file
%handles.filename = strcat(path,file); %set filename
set(handles.inputFile,'String',strcat(path,file)); %write filename to input text field
set(handles.cmd_runTool,'Enable','on'); %enable runTool button

set(handles.generalRadiobutton, 'Enable', 'on'); % enable buttons
set(handles.specificRadiobutton,'Enable','on');

guidata(hObject, handles);


% --- Executes on button press in cmd_runTool.
function cmd_runTool_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_runTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic
set(handles.statusField,'String','Importing Data.'); %write to status field
file = get(handles.inputFile,'string');
[rownum,column_names,error] = xls2db(file); %run db script

%UPDATE: remove status field for waitbar
if error == true
    set(handles.statusField,'String','Error importing data.'); %write to status field
else
    set(handles.statusField,'String','XLS2DB successful.'); %write to status field
end

rfind(rownum,column_names);
set(handles.statusField,'String','RFIND successful.'); %write to status field
plotr(column_names);
timer = toc;
mesg = sprintf('Completed in %f seconds',timer);
set(handles.statusField,'String',mesg); %write to status field
%
guidata(hObject,handles); %update handles structure


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

saveState(hObject, handles); % call to saveState function
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Save the state of the GUI.
function saveState(hObject, handles)
% handles   structure with handles and user data (see GUIDATA)
state.file = get(handles.inputFile, 'string'); % get the full name
state.generalRadiobutton = get(handles.generalRadiobutton, 'value');
state.specificRadiobutton = get(handles.specificRadiobutton, 'value');
state.specificTextfield = get(handles.specificTextfield, 'string');

save('state.mat', 'state'); % save to state.mat
% Update handles structure
guidata(hObject, handles);


% --- Load the prev state of the GUI.
function loadState(hObject, handles)
% handles    structure with handles and user data (see GUIDATA)

prevstate = 'state.mat';

if exist(prevstate, 'file')
    load(prevstate);
    %handles.filename = state.file;
    set(handles.inputFile,'String', state.file);
    set(handles.generalRadiobutton, 'value', state.generalRadiobutton);
    set(handles.specificRadiobutton, 'value', state.specificRadiobutton);
    set(handles.specificTextfield, 'string', state.specificTextfield);
    
    % IF no file in saved state, disable run button
    if strcmp(state.file,'PATH_TO_FILE')
        set(handles.cmd_runTool,'Enable','off'); %disable runTool button
        set(handles.generalRadiobutton, 'Enable', 'off'); % disable buttons
        set(handles.specificRadiobutton,'Enable','off');
    else
        set(handles.cmd_runTool,'Enable','on'); %enable runTool button
        set(handles.generalRadiobutton, 'Enable', 'on'); % enable buttons
        set(handles.specificRadiobutton,'Enable','on');
    end
    delete(prevstate)
    
    % IF SPECIFIC - RUN GETCOLUMNS
    if(get(handles.specificRadiobutton, 'Value') == 1)  
      set(handles.specificTextfield,'Enable','on');
      set(handles.columnNamePopup,'Enable','on');
      file = get(handles.inputFile,'String');
      [column_names, ~] = getColumnnames(file);
      set(handles.columnNamePopup,'String',column_names); % column_names is popup menu tag 
    end
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in columnNamePopup.
function columnNamePopup_Callback(hObject, eventdata, handles)
% hObject    handle to columnNamePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns columnNamePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        columnNamePopup

% --- Executes during object creation, after setting all properties.
function columnNamePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to columnNamePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in generalRadiobutton.
function generalRadiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to generalRadiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of generalRadiobutton
% get(hObject, 'Value');
%If general radio button selected deselect specific radio button and make
%contents not visible.
if(get(hObject, 'Value') == get(hObject, 'Max')) 
    set(handles.specificRadiobutton, 'Value', 0);
    set(handles.specificTextfield,'Enable','off');
    set(handles.columnNamePopup,'Enable','off');
end


% --- Executes on button press in specificRadiobutton.
function specificRadiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to specificRadiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of specificRadiobutton
% get(hObject, 'Value');
%Make specificTextfield and columnNamePopup visible
set(handles.specificTextfield,'Enable','on');
set(handles.columnNamePopup,'Enable','on');

%If specific radio button selected deselect general radio button and call
%getColumnnames to get column names and populate popup menu
if(get(hObject, 'Value') == get(hObject, 'Max')) 
    set(handles.generalRadiobutton, 'Value', 0);
    file = get(handles.inputFile,'String');
    [column_names, ~] = getColumnnames(file);
    
    set(handles.columnNamePopup,'String',column_names); % column_names is popup menu tag 
end
guidata(hObject, handles);

function [column_names,error] = getColumnnames(file)
column_names = '';
error = false;
h = waitbar(0,'Please wait...'); % Progress bar
% Read XLS file to call array RAW and get size
try
    waitbar(.1, h, 'Reading Excel File:');
    [~,~,raw] = xlsread(file);
catch MException
    % If there is a fault close the function
    disp(MException.message);
    error = true;
    waitbar(1,h,'Error');
    delete(h);
    return
end
[~,colnum] = size(raw);

% Save the names of the columns in a cell array
column_names = cell(1,colnum);

for i = 1:colnum
    column_names(i) = cellstr(sprintf('%s',char(raw(1,i))));
end

waitbar(1, h, 'Complete');
delete(h);