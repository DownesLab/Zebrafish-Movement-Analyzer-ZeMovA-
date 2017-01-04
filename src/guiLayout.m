function varargout = guiLayout(varargin)
% GUILAYOUT MATLAB code for guiLayout.fig
%      GUILAYOUT, by itself, creates a new GUILAYOUT or raises the existing
%      singleton*.
%
%      H = GUILAYOUT returns the handle to a new GUILAYOUT or the handle to
%      the existing singleton*.
%
%      GUILAYOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUILAYOUT.M with the given input arguments.
%
%      GUILAYOUT('Property','Value',...) creates a new GUILAYOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiLayout_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiLayout_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiLayout

% Last Modified by GUIDE v2.5 03-Jan-2017 16:23:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiLayout_OpeningFcn, ...
                   'gui_OutputFcn',  @guiLayout_OutputFcn, ...
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


% --- Executes just before guiLayout is made visible.
function guiLayout_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiLayout (see VARARGIN)

% Choose default command line output for guiLayout
handles.output = hObject;
set(handles.buttonPlayPause,'Enable','off');
set(handles.buttonPrevFrame,'Enable','off');
set(handles.buttonNextFrame,'Enable','off');
I=zeros(480,640);
axes(handles.axesFigure);
imshow(I);
drawnow;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiLayout wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guiLayout_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderVid_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderVid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in buttonLoad.
function buttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[vidFile,vidFilePath]=uigetfile('*.avi'); %Filter .avi files
vidFile=[vidFilePath,vidFile];
videoSource = VideoReader(vidFile);
handles.data.imgSequence=[]; %create ab array for the video images
frameCount=1;
while hasFrame(videoSource); %read frame, convert to grayscale and store it
    I=readFrame(videoSource);
    I=im2double(rgb2gray(I));
    handles.data.imgSequence(:,:,frameCount)=I;
    frameCount=frameCount+1;
end
handles.data.prImgSequence=zeros(size(handles.data.imgSequence)); %array for processed Frames
handles.data.currentFrame=1;
handles.data.playFlag=1;
% Enable video controls after loading is complete
set(handles.buttonPlayPause,'Enable','on'); 
set(handles.buttonPrevFrame,'Enable','on');
set(handles.buttonNextFrame,'Enable','on');
guidata(hObject,handles);



% --- Executes on button press in buttonExport.
function buttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonCorrect.
function buttonCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('hello')


% --- Executes during object creation, after setting all properties.
function axesFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% Hint: place code in OpeningFcn to populate axesFigure


% --- Executes on button press in buttonPlayPause.
function buttonPlayPause_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPlayPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(handles.buttonPlayPause,'String'),'Play')) %on running the video after loading it
%     uiresume();
    set(handles.buttonPlayPause,'String','Pause'); 
%     handles.data.currentFrame=1;
    handles.data.playFlag=1;
    i = handles.data.currentFrame;
    while (i<=size(handles.data.imgSequence,3) && handles.data.playFlag==1)
        guidata(hObject, handles);
        handles.data.currentFrame=i;
        axes(handles.axesFigure);
        imshow(handles.data.imgSequence(:,:,i));
        guidata(hObject, handles);
        drawnow;
        handles=guidata(hObject);
        i=i+1;
    end
    if handles.data.currentFrame==size(handles.data.imgSequence,3)
        set(handles.buttonPlayPause,'String','Play'); 
        handles.data.currentFrame=1;
        guidata(hObject,handles);
    end
else
        set(handles.buttonPlayPause,'String','Play');
        handles.data.playFlag=0;
        guidata(hObject, handles);
end


% --- Executes on button press in buttonPrevFrame.
function buttonPrevFrame_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrevFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pause the video, then reduce the frame by 1
if handles.data.currentFrame<=1
    return;
end
set(handles.buttonPlayPause,'String','Play');
handles.data.currentFrame=handles.data.currentFrame-1;
axes(handles.axesFigure);
imshow(handles.data.imgSequence(:,:,handles.data.currentFrame));
handles.data.playFlag=0;
guidata(hObject, handles);






% --- Executes on button press in buttonNextFrame.
function buttonNextFrame_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNextFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.data.currentFrame==size(handles.data.imgSequence,3)
    return;
end
set(handles.buttonPlayPause,'String','Play');
handles.data.currentFrame=handles.data.currentFrame+1;
axes(handles.axesFigure);
imshow(handles.data.imgSequence(:,:,handles.data.currentFrame));
handles.data.playFlag=0;
guidata(hObject, handles);
