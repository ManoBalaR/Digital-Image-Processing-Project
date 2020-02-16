function varargout = licenseplate(varargin)
% LICENSEPLATE MATLAB code for licenseplate.fig
%      LICENSEPLATE, by itself, creates a new LICENSEPLATE or raises the existing
%      singleton*.
%
%      H = LICENSEPLATE returns the handle to a new LICENSEPLATE or the handle to
%      the existing singleton*.
%
%      LICENSEPLATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LICENSEPLATE.M with the given input arguments.
%
%      LICENSEPLATE('Property','Value',...) creates a new LICENSEPLATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before licenseplate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to licenseplate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help licenseplate

% Last Modified by GUIDE v2.5 15-May-2012 16:44:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @licenseplate_OpeningFcn, ...
                   'gui_OutputFcn',  @licenseplate_OutputFcn, ...
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


% --- Executes just before licenseplate is made visible.
function licenseplate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to licenseplate (see VARARGIN)

% Choose default command line output for licenseplate
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes licenseplate wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = licenseplate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in StartKnop.
function StartKnop_Callback(hObject, eventdata, handles)
% hObject    handle to StartKnop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%ophalen afbeelding
naam=get(handles.naam,'String');
A=imread(strcat('images/',naam));
org=A;
axes(handles.axes1);
[h,w,f]=size(A);
%originele afbeelding wordt getoond
imshow(A);
%we converteren de afbeelding naar grijsschaal om een treshhold te kunnen
%opstellen voor de binaire afbeelding: alles onder de treshold is 1, alles daarboven wordt 0
A = rgb2gray(A);
level = graythresh(A);
%de afbeelding wordt omgezet naar een binaire afbeelding, we verhogen de
%treshold nog met 30% voor een beter resultaat te krijgen
A = im2bw(A,level*1.3);
axes(handles.axes2);
%vervolgens maken we gebruik van een ingebouwde matlab-functie voor
%edge-detection adhv 
A=edge(A,'prewitt');
imshow(A);

horHist=zeros(w);
%Het aantal witte pixels per kolom worden opgeteld en opgeslagen
for i=1:w
    tot=0;
    for j=1:h
        if (A(j,i)==1)
            tot=tot+1;
        end
    end
    horHist(i)=tot;
end
axes(handles.axes3);
%berekende treshold 
gem=max(horHist)/2.3;
plot(horHist);
hstart=0;
heinde=0;
width=0;
hcounter=0;
arc=0;
hcoor=zeros(1,2);
%als het aantal witte pixels gedurende een bepaalde afstand (vastgelegd in percentages) groter is dan de
%treshold wordt deze positie opgeslagen als de horizontale positie van de
%nummerplaat
for i=1:w
    if horHist(i)>gem(1)
        if(hstart==0)
            hstart=i;
        end
        hcounter=0;
    else
        if hstart>0
            if hcounter>(w*0.07)
                heinde=i-hcounter;
                width=heinde-hstart;
                if(width>(w*0.1))
                    arc=arc+1;
                    hcoor(arc,1)=hstart;
                    hcoor(arc,2)=width;
                end
                hstart=0;
                hcounter=0;
                heinde=0;
                width=0;
            end
            hcounter=hcounter+1;
        end
    end
end
[ww,f]=size(hcoor);
hstart=0;
hwidth=0;
%in het geval er meerdere horizontale plaatsen gevonden zijn voor de
%nummerplaat dan pikken we enkel de breedste positie er uit.
for i=1:ww
    if(hcoor(i,2)>hwidth)
        hwidth=hcoor(i,2);
        hstart=hcoor(i,1);
    end
end

A=A(:,hstart:(hstart+hwidth),:);
axes(handles.axes2);
imshow(A);
verHist=zeros(h);
%het aantal keer dat een pixel en zijn buur in een rij tegenovergesteld
%zijn van elkaar wordt opgeslagen voor die rij.
for j=1:h
    tot=0;
    for i=2:hwidth
        if (A(j,i-1)==1 && A(j,i)==0) || (A(j,i-1)==0 && A(j,i)==1) 
            tot=tot+1;
        end
    end
    verHist(j)=tot;
end
axes(handles.axes4);
verh=zeros(1);
coun=1;
%we berekenen de gemiddelde waarde van het aantal tegenovergestelde
%naburige pixels in een rij, dat gemiddelde gebruiken we later als treshold
for i=1:h
    if(verHist(i)>0)
        verh(coun)=verHist(i);
        coun=coun+1;
    end
end
gem=mean(verh)
plot(verHist);
vstart=0;
veinde=0;
height=0;
vcounter=0;
arc=0;
vcoor=zeros(1,2);
h*0.07
%als het aantal tegenovergestelde naburige pixels per rij gedurende een
%bepaalde breedte groter is dan het gemiddelde en vervolgens van een
%bepaalde hoogte is tov de afmetingen van de afbeelding, dan wordt deze
%positie opgeslagen als mogelijke verticale plaats van de nummerplaat
for(i=1:h)
    if verHist(i)>gem(1)
        if(vstart==0)
            vstart=i;
        end
        vcounter=0;
    else
        if vstart>0
            if vcounter>(h*0.03)
                veinde=i-vcounter;
                height=veinde-vstart;
                if(height>(h*0.05))
                    arc=arc+1;
                    vcoor(arc,1)=vstart;
                    vcoor(arc,2)=height;
                end
                vstart=0;
                vcounter=0;
                veinde=0;
                height=0;
            end
            vcounter=vcounter+1;
        end
    end
end
[l,f]=size(vcoor);
axes(handles.axes5);
%nu we de verschillende mogelijke posities berekend hebben kunnen we
%overgaan tot de segmentatie
A=org(vcoor(l,1):vcoor(l,1)+vcoor(l,2),hstart:(hstart+hwidth),:);
imshow(A);
axes(handles.axes6);
%tot slot worden de tekens op de nummerplaat gesegmenteerd en herkend (zie
%ocr.m file)
f=ocr(A);
set(handles.plaat,'String',f);
function naam_Callback(hObject, eventdata, handles)
% hObject    handle to naam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of naam as text
%        str2double(get(hObject,'String')) returns contents of naam as a double


% --- Executes during object creation, after setting all properties.
function naam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to naam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plaat_Callback(hObject, eventdata, handles)
% hObject    handle to plaat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plaat as text
%        str2double(get(hObject,'String')) returns contents of plaat as a double


% --- Executes during object creation, after setting all properties.
function plaat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plaat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
