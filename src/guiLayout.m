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

% Last Modified by GUIDE v2.5 21-Aug-2017 08:53:16

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
set(handles.buttonPlayPause,'String','Play'); 
set(handles.buttonPlayPause,'Enable','off');
set(handles.buttonPrevFrame,'Enable','off');
set(handles.buttonNextFrame,'Enable','off');
set(handles.buttonExport,'Enable','off');
set(handles.buttonCorrect,'Enable','off');
set(handles.sliderVid,'Enable','off');
set(handles.buttonNextUFrame,'Enable','off');
set(handles.buttonPrevUFrame,'Enable','off');
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
value=handles.sliderVid.Value;
value=round(value,0);
handles.data.currentFrame=value;
axes(handles.axesFigure);
imshow(handles.data.prImgSequence(:,:,:,handles.data.currentFrame));
handles.textAngleWindow.String=num2str(handles.data.points{handles.data.currentFrame,1}.angle);
handles.textFrameWindow.String=sprintf('%d / %d',handles.data.currentFrame,handles.data.nFrames);
guidata(hObject,handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over sliderVid.
function sliderVid_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to sliderVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% value=handles.sliderVid.Value;
% value=round(value,0);
% handles.data.currentFrame=value;
% axes(handles.axesFigure);
% imshow(handles.data.prImgSequence(:,:,handles.data.currentFrame));
% guidata(hObject,handles);


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
set(handles.buttonPlayPause,'String','Play'); 
set(handles.buttonPlayPause,'Enable','off');
set(handles.buttonPrevFrame,'Enable','off');
set(handles.buttonExport,'Enable','off');
set(handles.buttonCorrect,'Enable','off');
set(handles.buttonNextFrame,'Enable','off');
set(handles.sliderVid,'Enable','off');
set(handles.buttonNextUFrame,'Enable','off');
set(handles.buttonPrevUFrame,'Enable','off');
[vidFile,vidFilePath]=uigetfile('*.avi'); %Filter .avi files
vidFile=[vidFilePath,vidFile];
if vidFile==0 %if dialog closed and no file selected
    return;
end
set(handles.panelVid,'Title',vidFile);
videoSource = VideoReader(vidFile);
handles.data.blockMask=zeros(videoSource.Height,videoSource.Width);
handles.data.imgSequence=uint8([]); %create ab array for the video images
handles.data.prImgSequence=uint8([]);
handles.data.points=cell(25,1);
handles.data.pixelMM=31;
handles.data.udFrames=uint8([]);
udFrameIndex=0;
frameCount=1;
while hasFrame(videoSource) %read frame, convert to grayscale and store it
    I=readFrame(videoSource);
    set(handles.textConsoleWindow,'String',['Analyzing Frame ',num2str(frameCount)]);
    I=rgb2gray(I);
    handles.data.imgSequence(:,:,frameCount)=I;
    points=getPoints(handles.data.imgSequence(:,:,frameCount),20);  
    if ~(isequal(points.head,[0 0])||isequal(points.body,[0 0]))
        v1=points.head-points.body;
        v2=points.tail-points.body;
        ang=atan2(v1(1)*v2(2)-v2(1)*v1(2),v1(1)*v2(1)+v1(2)*v2(2));
        points.angle=round(mod(-180/pi*ang,360),1)-180.0;
        sz=size(handles.data.imgSequence(:,:,frameCount));
        mask=zeros(sz(1),sz(2),3,'uint8');
        mask(points.head(1,1),points.head(1,2),1)=255;
        mask(points.body(1,1),points.body(1,2),:)=255;
        mask(points.tail(1,1),points.tail(1,2),:)=255;
        se=strel('disk',3);
        mask=imdilate(mask,se);
        
        % Line between body tail points
        [cx, cy, ~]=improfile(mask,[points.body(1,1) points.tail(1,1)],[points.body(1,2) points.tail(1,2)]);
        cx=round(cx);
        cy=round(cy);
        for i = 1:length(cx)
            mask(cx(i),cy(i),:)=255;
        end
        
        % Line between body and head
        [cx, cy, ~]=improfile(mask,[points.body(1,1) points.head(1,1)],[points.body(1,2) points.head(1,2)]);
        cx=round(cx);
        cy=round(cy);
        for i = 1:length(cx)
            mask(cx(i),cy(i),:)=255;
        end
        mask(points.head(1,1),points.head(1,2),1)=255;
        
        rgbImage = cat(3, handles.data.imgSequence(:,:,frameCount),handles.data.imgSequence(:,:,frameCount),handles.data.imgSequence(:,:,frameCount));
        handles.data.prImgSequence(:,:,:,frameCount)=imadd(rgbImage,mask);
    else
        udFrameIndex=udFrameIndex+1;
        handles.data.udFrames(udFrameIndex,1)=frameCount;
        points.angle=500;
        rgbImage = cat(3, handles.data.imgSequence(:,:,frameCount),handles.data.imgSequence(:,:,frameCount),handles.data.imgSequence(:,:,frameCount));
        handles.data.prImgSequence(:,:,:,frameCount)=rgbImage;
    end
    handles.data.points{frameCount,1}=points;
    frameCount=frameCount+1;
end
handles.data.nFrames=frameCount-1;
handles.data.currentFrame=1;
handles.data.playFlag=1;
% Enable video controls after loading is complete
handles.sliderVid.Value=1;
handles.sliderVid.Min=1;
handles.sliderVid.Max=frameCount-1;
slidStep=1.0/(handles.sliderVid.Max-1);
handles.sliderVid.SliderStep=[slidStep slidStep];
axes(handles.axesFigure);
imshow(handles.data.prImgSequence(:,:,:,handles.data.currentFrame));
handles.textAngleWindow.String=num2str(handles.data.points{handles.data.currentFrame,1}.angle);
handles.textFrameWindow.String=sprintf('%d / %d',handles.data.currentFrame,handles.data.nFrames);
handles.sliderVid.Value=handles.data.currentFrame;
set(handles.buttonPlayPause,'Enable','on'); 
set(handles.buttonPrevFrame,'Enable','on');
set(handles.buttonNextFrame,'Enable','on');
set(handles.buttonExport,'Enable','on');
set(handles.buttonCorrect,'Enable','on');
set(handles.sliderVid,'Enable','on');
set(handles.textConsoleWindow,'String',strcat('Ready - Undetected Frames: ',num2str(udFrameIndex)));
set(handles.buttonNextUFrame,'Enable','on');
set(handles.buttonPrevUFrame,'Enable','on');
guidata(hObject,handles);



% --- Executes on button press in buttonExport.
function buttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Save analysis file and data
setEnable(handles,'off');


data=handles.data;
points=handles.data.points;
headXY=single(zeros(data.nFrames,2));
headXY(1,1)=points{1}.head(1)/data.pixelMM;
headXY(1,2)=points{1}.head(2)/data.pixelMM;
angVelocity=single(zeros(data.nFrames,1));
velocity=single(zeros(data.nFrames,1));
angVelocity(1,1)=0;
velocity(1,1)=0;
angle=single(zeros(data.nFrames,1));
angle(1,1)=points{1}.angle;
fps=inputdlg('Enter the recorded frames per second rate of the video');
fps=str2num(fps{1});
durationPerFrameMS=1000/fps;
data.frameTime=zeros(data.nFrames,1);
data.frameTime(1)=0;
for i = [2:data.nFrames]
    data.frameTime(i)=(i-1)*durationPerFrameMS;
    angle(i,1)=points{i}.angle;
    headXY(i,1)=points{i}.head(1)/data.pixelMM;
    headXY(i,2)=points{i}.head(2)/data.pixelMM;
    angVelocity(i,1)=(points{i}.angle-points{i-1}.angle)/(data.frameTime(i)-data.frameTime(i-1));
    distance=sqrt((headXY(i,1)-headXY(i-1,1)).^2+(headXY(i,2)-headXY(i-1,2)).^2);
    velocity(i,1)=distance/(data.frameTime(i)-data.frameTime(i-1));
end
Tbl=table(data.frameTime,angle,angVelocity,headXY(:,1),headXY(:,2),velocity,'VariableNames',{'Time','Curl','CurlVelocity','HeadPositionX','HeadPositionY','LinearVelocity'});
[fName, fPath]=uiputfile('*.xlsx', 'Save analysis data');
if fName==0 %if dialog closed and no file selected
    setEnable(handles,'on');
    return;
end
writetable(Tbl,[fPath fName]);
k=strfind(fName,'.');
fName=fName(1:k-1);
fName=[fName '.mat'];
save([fPath fName],'data');

setEnable(handles,'on');



% --- Executes on button press in buttonCorrect.
function buttonCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setEnable(handles,'off');

axes(handles.axesFigure);
frame=handles.data.currentFrame;
% imshow(handles.data.imgSequence(:,:,frame));
handles.data.points{frame,1}.head=[0 0];
handles.data.points{frame,1}.body=[0 0];
handles.data.points{frame,1}.tail=[0 0];

handles.textConsoleWindow.String='Select points in the order - head, body, tail. Press Enter when done';
[c, r, ~]=impixel(handles.data.imgSequence(:,:,frame));
if any(c<0)||any(r<0)||any(c>size(handles.data.imgSequence,2))||any(r>size(handles.data.imgSequence,1))
    handles.textConsoleWindow.String='Values out of bounds of the image, try again';
    setEnable(handles,'on');
    return;
end
handles.textConsoleWindow.String='';
sz=size(handles.data.imgSequence(:,:,frame));
mask=zeros(sz(1),sz(2),3,'uint8');
for i=1:3
    switch i
        case 1
            mask(r(i),c(i),1)=255;
            handles.data.points{frame,1}.head=[r(i) c(i)];
        case 2
            mask(r(i),c(i),:)=255;
            handles.data.points{frame,1}.body=[r(i) c(i)];
        case 3
            mask(r(i),c(i),:)=255;
            handles.data.points{frame,1}.tail=[r(i) c(i)];
    end
end
points=handles.data.points{frame,1};
v1=points.head-points.body;
v2=points.tail-points.body;
ang=atan2(v1(1)*v2(2)-v2(1)*v1(2),v1(1)*v2(1)+v1(2)*v2(2));
handles.data.points{frame,1}.angle=round(mod(-180/pi*ang,360),1)-180.0;
se=strel('disk',3);
mask=imdilate(mask,se);
% Line between body tail points
[cx, cy, ~]=improfile(mask,[points.body(1,1) points.tail(1,1)],[points.body(1,2) points.tail(1,2)]);
cx=round(cx);
cy=round(cy);
for i = [1:length(cx)]
    mask(cx(i),cy(i),:)=255;
end

% Line between body and head
[cx, cy, ~]=improfile(mask,[points.body(1,1) points.head(1,1)],[points.body(1,2) points.head(1,2)]);
cx=round(cx);
cy=round(cy);
for i = [1:length(cx)]
    mask(cx(i),cy(i),:)=255;
end
rgbImage = cat(3, handles.data.imgSequence(:,:,frame),handles.data.imgSequence(:,:,frame),handles.data.imgSequence(:,:,frame));
handles.data.prImgSequence(:,:,:,frame)=imadd(rgbImage,mask);
imshow(handles.data.prImgSequence(:,:,:,frame));
setEnable(handles,'on');
guidata(hObject,handles);



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
    set(handles.buttonPlayPause,'String','Pause'); 
    handles.data.playFlag=1;
    i=handles.data.currentFrame;
    while (i<=size(handles.data.imgSequence,3) && handles.data.playFlag==1)
        guidata(hObject, handles);
        handles.data.currentFrame=i;
        handles.textAngleWindow.String=num2str(handles.data.points{i,1}.angle);
        handles.textFrameWindow.String=sprintf('%d / %d',i,handles.data.nFrames);
        axes(handles.axesFigure);
        imshow(handles.data.prImgSequence(:,:,:,i));
        handles.sliderVid.Value=i;
        guidata(hObject, handles);
        drawnow;
        handles=guidata(hObject);
        if(handles.data.currentFrame~=i)
            i=handles.data.currentFrame;
        else
            i=i+1;
        end
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
imshow(handles.data.prImgSequence(:,:,:,handles.data.currentFrame));
handles.textAngleWindow.String=num2str(handles.data.points{handles.data.currentFrame,1}.angle);
handles.textFrameWindow.String=sprintf('%d / %d',handles.data.currentFrame,handles.data.nFrames);
handles.data.playFlag=0;
handles.sliderVid.Value=handles.data.currentFrame;
guidata(hObject, handles);






% --- Executes on button press in buttonNextFrame.
function buttonNextFrame_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNextFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.data.currentFrame==size(handles.data.imgSequence,3) %Check if the current frame is the last one
    return;
end
set(handles.buttonPlayPause,'String','Play');
handles.data.currentFrame=handles.data.currentFrame+1;
axes(handles.axesFigure);
imshow(handles.data.prImgSequence(:,:,:,handles.data.currentFrame));
handles.textAngleWindow.String=num2str(handles.data.points{handles.data.currentFrame,1}.angle);
handles.textFrameWindow.String=sprintf('%d / %d',handles.data.currentFrame,handles.data.nFrames);
handles.sliderVid.Value=handles.data.currentFrame;
handles.data.playFlag=0;
guidata(hObject, handles);



function editConsole_Callback(hObject, eventdata, handles)
% hObject    handle to editConsole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editConsole as text
%        str2double(get(hObject,'String')) returns contents of editConsole as a double


% --- Executes during object creation, after setting all properties.
function editConsole_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editConsole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function setEnable(handles,value)
set(handles.buttonLoad,'Enable',value);
set(handles.buttonPlayPause,'Enable',value);
set(handles.buttonPrevFrame,'Enable',value);
set(handles.buttonExport,'Enable',value);
set(handles.buttonCorrect,'Enable',value);
set(handles.buttonNextFrame,'Enable',value);
set(handles.sliderVid,'Enable',value);
set(handles.buttonLoadAnalysis,'Enable',value);
set(handles.buttonCallibrate,'Enable',value);
set(handles.buttonNextUFrame,'Enable',value);
set(handles.buttonPrevUFrame,'Enable',value);


% --- Executes on button press in buttonLoadAnalysis.
function buttonLoadAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.buttonPlayPause,'String','Play'); 
set(handles.buttonPlayPause,'Enable','off');
set(handles.buttonPrevFrame,'Enable','off');
set(handles.buttonExport,'Enable','off');
set(handles.buttonCorrect,'Enable','off');
set(handles.buttonNextFrame,'Enable','off');
set(handles.sliderVid,'Enable','off');
[dataFile,dataPath]=uigetfile('*.mat'); %Filter .avi files
if dataFile==0
    return;
end
load([dataPath dataFile],'data');
if exist('data')~=1
    set(handles.textConsoleWindow,'String','The loaded file is not valid, please try again');
    return;
end
handles.data=data;
handles.data.currentFrame=1;
handles.data.playFlag=1;
handles.sliderVid.Value=1;
handles.sliderVid.Min=1;
handles.sliderVid.Max=length(handles.data.frameTime);
slidStep=1.0/(handles.sliderVid.Max-1);
handles.sliderVid.SliderStep=[slidStep slidStep];
setEnable(handles,'on');
handles.textConsoleWindow.String='Ready';
guidata(hObject,handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if length(eventdata.Modifier)>=1 && strcmp(eventdata.Modifier{1},'control')
    if strcmpi(eventdata.Key,'o') && strcmpi(handles.buttonLoadAnalysis.Enable,'on')
        uicontrol(handles.buttonLoadAnalysis);
        buttonLoadAnalysis_Callback(handles.buttonLoadAnalysis,[],handles);
    elseif strcmpi(eventdata.Key,'n') && strcmpi(handles.buttonLoad.Enable,'on')
        uicontrol(handles.buttonLoad);
        buttonLoad_Callback(handles.buttonLoadAnalysis,[],handles);
    elseif strcmpi(eventdata.Key,'s') && strcmpi(handles.buttonExport.Enable,'on')
        uicontrol(handles.buttonExport);
        buttonExport_Callback(handles.buttonExport,[],handles);
    end
elseif strcmpi(eventdata.Key,'p')&& strcmpi(handles.buttonPlayPause.Enable,'on')
    uicontrol(handles.buttonPlayPause);
    buttonPlayPause_Callback(handles.buttonPlayPause,[],handles);
elseif strcmpi(eventdata.Key,'c')&& strcmpi(handles.buttonCorrect.Enable,'on')
    uicontrol(handles.buttonCorrect);
    buttonCorrect_Callback(handles.buttonCorrect,[],handles);
elseif strcmpi(eventdata.Key,'a')&& strcmpi(handles.buttonPrevFrame.Enable,'on')
    uicontrol(handles.buttonPrevFrame);
    buttonPrevFrame_Callback(handles.buttonPrevFrame,[],handles);
elseif strcmpi(eventdata.Key,'d')&& strcmpi(handles.buttonNextFrame.Enable,'on')
    uicontrol(handles.buttonNextFrame);
    buttonNextFrame_Callback(handles.buttonNextFrame,[],handles);
end


% --- Executes on button press in buttonHelp.
function buttonHelp_Callback(hObject, eventdata, handles)
% hObject    handle to buttonHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
message=sprintf('The following are the shortcut keys (Case insensitive)\n');
message=[message sprintf(' %-16s : %-6s\n','Load Video','Ctrl + N')];
message=[message sprintf(' %-15s : %-6s\n','Load Analysis','Ctrl + O')];
message=[message sprintf(' %-20s : %-6s\n','Correct','C')];
message=[message sprintf(' %-14s : %-6s\n','Export Analysis','Ctrl + S')];
message=[message sprintf(' %-17s : %-6s\n','Play / Pause','P')];
message=[message sprintf(' %-14s : %-6s\n','Previous Frame','A')];
message=[message sprintf(' %-17s : %-6s\n','Next Frame','D')];
set(0,'DefaultAxesFontName','Algerian')
uiwait(msgbox(message,'Help','modal'));

% --- Executes on button press in buttonAbout.
function buttonAbout_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
message=sprintf('ZebraFish Movement Analyzer (ZeMovA) v1.1 \n');
message=[message sprintf('For any queries please contact Prof. Gerald B. Downes (gbdownes@bio.umass.edu)')];
uiwait(msgbox(message,'About','modal'));


% --- Executes on button press in buttonCallibrate.
function buttonCallibrate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCallibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[scaleFile,scalePath]=uigetfile('*','Select the scale image');
if(scaleFile==0)
    return;
end
scale=imread([scalePath scaleFile]); 
axes(handles.axesFigure);
imshow(scale);
handles.textConsoleWindow.String='Select the endpoints of the scale';
[c r p]=impixel(scale);
pixelDist=abs(c(2)-c(1));
mmDist=inputdlg('Enter the distance in mm between the marked points');
mmDist=mmDist{1}-'0';
handles.data.pixelMM=floor(pixelDist*1.0/mmDist);
guidata(hObject,handles);


% --- Executes on button press in buttonNextUFrame.
% This method is called when the button Next Undetected Frame is
% pressed
function buttonNextUFrame_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNextUFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.buttonPlayPause,'String','Play');
udFrames=handles.data.udFrames;
% Not implementing a method like binary search because it won't be worth it
udFrameIndex=find(handles.data.udFrames>handles.data.currentFrame); 
if ~isempty(udFrameIndex)
    handles.data.currentFrame=udFrames(udFrameIndex(1));
    axes(handles.axesFigure);
    imshow(handles.data.prImgSequence(:,:,:,handles.data.currentFrame));
    handles.textAngleWindow.String='';
    handles.textFrameWindow.String=sprintf('%d / %d',handles.data.currentFrame,handles.data.nFrames);
    handles.sliderVid.Value=handles.data.currentFrame;
end
handles.data.playFlag=0;
guidata(hObject, handles);


% --- Executes on button press in buttonPrevUFrame.
% This method is called when the button Previous Undetected Frame is
% pressed
function buttonPrevUFrame_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrevUFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.buttonPlayPause,'String','Play');
udFrames=handles.data.udFrames;
% Not implementing a method like binary search because it won't be worth it
udFrameIndex=find(handles.data.udFrames<handles.data.currentFrame); 
if ~isempty(udFrameIndex)
    handles.data.currentFrame=udFrames(udFrameIndex(length(udFrameIndex)));
    axes(handles.axesFigure);
    imshow(handles.data.prImgSequence(:,:,:,handles.data.currentFrame));
    handles.textAngleWindow.String='';
    handles.textFrameWindow.String=sprintf('%d / %d',handles.data.currentFrame,handles.data.nFrames);
    handles.sliderVid.Value=handles.data.currentFrame;
end
handles.data.playFlag=0;
guidata(hObject, handles);
