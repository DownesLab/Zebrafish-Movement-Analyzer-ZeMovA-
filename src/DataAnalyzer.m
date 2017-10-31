function varargout = DataAnalyzer(varargin)
% DATAANALYZER MATLAB code for DataAnalyzer.fig
%      DATAANALYZER, by itself, creates a new DATAANALYZER or raises the existing
%      singleton*.
%
%      H = DATAANALYZER returns the handle to a new DATAANALYZER or the handle to
%      the existing singleton*.
%
%      DATAANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAANALYZER.M with the given input arguments.
%
%      DATAANALYZER('Property','Value',...) creates a new DATAANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataAnalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataAnalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataAnalyzer

% Last Modified by GUIDE v2.5 31-Oct-2017 03:55:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataAnalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @DataAnalyzer_OutputFcn, ...
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


% --- Executes just before DataAnalyzer is made visible.
function DataAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataAnalyzer (see VARARGIN)

% Choose default command line output for DataAnalyzer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataAnalyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataAnalyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadFile.
function loadFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get the file
[dataFileName,dataFilePath]=uigetfile('*.xlsx');
dataFile=[dataFilePath,dataFileName];
if dataFile==0 % when dialog is closed and no file is selected
    return;
end
tbl=readtable(dataFile);
% Add file to the file list
numElements=length(handles.fileListBox.String);
if numElements==0
    handles.fileListBox.String={};
end
handles.fileListBox.String(numElements+1)={dataFileName};
obj=KinematicAnalysis(tbl,true,[34, 226]);
guidata(hObject,handles);


% --- Executes on selection change in plotMenu.
function plotMenu_Callback(hObject, eventdata, handles)
% hObject    handle to plotMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotMenu


% --- Executes during object creation, after setting all properties.
function plotMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fileListBox.
function fileListBox_Callback(hObject, eventdata, handles)
% hObject    handle to fileListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileListBox


% --- Executes during object creation, after setting all properties.
function fileListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
