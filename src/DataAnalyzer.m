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

% Last Modified by GUIDE v2.5 13-Nov-2017 21:12:25

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
handles.fishObjs=containers.Map;
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
% determine the fish name, dpf and genotype - The file should be named as
% fish name_dpf_genotype
name=strsplit(dataFileName,'.');
name
name=name{1};
name=char(strsplit(name,'_'));
fishName=name(1,:);
dpf=name(2,:);
genotype=name(3,:);

handles.fileListBox.String(numElements+1)={fishName};
handles.fishObjs(fishName)=KinematicAnalysis(tbl,genotype,dpf,true,[34, 226]);
% handles.fishObjs(dataFileName)=KinematicAnalysis(tbl,true,[42, 532]);
guidata(hObject,handles);


% --- Executes on selection change in plotMenu.
function plotMenu_Callback(hObject, eventdata, handles)
% hObject    handle to plotMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotMenu
if(handles.plotMenu.Value==2)
    handles.fileListBox.Max=1;
    handles.fileListBox.Min=1;
    handles.fileListBox.Value=[1];
else
    handles.fileListBox.Max=10;
    handles.fileListBox.Min=1;
    handles.fileListBox.Value=[1];
end
guidata(hObject,handles);


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


% --- Executes on button press in plotButton.
function plotButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get the selected plot type and fishes
plotSelection=handles.plotMenu.Value;
% The following are the current values for plot selections:
% 1 - select plot (invalid)
% 2 - body bend plot
% 3 - body angle plot
% 4 - trajectory plot
fileNames=handles.fileListBox.String(handles.fileListBox.Value);
cla(handles.plotAxes)
if(plotSelection==2)
    obj=handles.fishObjs(char(fileNames(1)));
    plot(handles.plotAxes,obj.time,obj.bodyAngle,'-o','MarkerIndices',obj.bendCoordinates(:,1)/2)
    ylim(handles.plotAxes,[-180 180]);
    xlim(handles.plotAxes,[0 obj.getDuration()+20]);
    xlabel(handles.plotAxes,obj.timeLabel)
    ylabel(handles.plotAxes,obj.bodyAngleLabel);
    
elseif(plotSelection==3)
    maxDuration=-1;
    for i= 1:length(fileNames)
        hold on
        obj=handles.fishObjs(char(fileNames(i)));
        plot(handles.plotAxes,obj.time,obj.bodyAngle);
        maxDuration=max(maxDuration,obj.getDuration());
    end
    ylim(handles.plotAxes,[-180 180])
    xlim(handles.plotAxes,[0 maxDuration+20]);
    xlabel(handles.plotAxes,obj.timeLabel)
    ylabel(handles.plotAxes,obj.bodyAngleLabel);
    legend(char(fileNames));
    
elseif (plotSelection==4)
     for i= 1:length(fileNames)
        hold on
        obj=handles.fishObjs(char(fileNames(i)));
        plot(handles.plotAxes,obj.getXCoordinatesFromOrigin,obj.getYCoordinatesFromOrigin);
     end
     ylim(handles.plotAxes,[-15 15]);
     xlim(handles.plotAxes,[-20 20]);
     xlabel(handles.plotAxes,obj.xLabel);
     ylabel(handles.plotAxes,obj.yLabel);
     legend(char(fileNames));
elseif (plotSelection==5)
    PlottingUtils.dotPlot(handles,fileNames);
end
guidata(hObject,handles);
