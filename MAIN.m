% =========================================================================
% =========================================================================
%                        DEEP-WATER DECONTAMINATION     
% =========================================================================
% =========================================================================

% Developed by: Nathaniel Mailhot
% GROUP: DDT1
% University of Ottawa
% Mechanical Engineering
% Latest Revision: 04/11/2020 by Eleni Sabourin

% =========================================================================
% SOFTWARE DESCRIPTION
% =========================================================================


function varargout = MAIN(varargin)
% MAIN MATLAB code for MAIN.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAIN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAIN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAIN

% Last Modified by GUIDE v2.5 10-Nov-2021 09:56:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MAIN_OpeningFcn, ...
                   'gui_OutputFcn',  @MAIN_OutputFcn, ...
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

% --- Outputs from this function are returned to the command line.
function varargout = MAIN_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% End initialization code - DO NOT EDIT

% =========================================================================
% =========================================================================
% --- Executes just before MAIN is made visible.
% =========================================================================
% =========================================================================

function MAIN_OpeningFcn(hObject, eventdata, handles, varargin) %#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MAIN (see VARARGIN)

% Choose default command line output for MAIN
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Set the default values on the GUI. It is recommended to choose a valid set 
%of default values as a starting point when the program launches.
clc

%Add the 'subfunctions' folder to the path so that subfunctions can be
%accessed
addpath('Subfunctions');

%Parameter Initialization
Min_excavation_depth = 10; %cm
Max_excavation_depth = 50; %cm
Default_excavation_depth = 25; %cm

Min_excavation_width = 1.5; %m
Max_excavation_width = 3.0; %m
Default_excavation_width = 2.0; %m

Min_operation_depth = 300; %m
Max_operation_depth = 3000; %m
Default_operation_depth = 1750; %m

Default_closing_time = 50; %s
%function to get min and max values
%[Min_closing_time,Max_closing_time] = GUIgetClosingTimeRange(Default_excavation_width);

%Set default values for excavation width slider and textbox
set(handles.Slider_excavation_width,'Value',Default_excavation_width);
set(handles.Slider_excavation_width,'Min',Min_excavation_width);
set(handles.Slider_excavation_width,'Max',Max_excavation_width);

set(handles.TXT_excavation_width,'String',num2str(Default_excavation_width));

%Set Min/Max values for excavation width slider and textbox
set(handles.excavation_width_range,'String', strcat("[", string(Min_excavation_width), ":", string(Max_excavation_width),"]"));


%Set default value for excavation depth slider and textbox
set(handles.Slider_excavation_depth,'Value',Default_excavation_depth);
set(handles.Slider_excavation_depth,'Min',Min_excavation_depth);
set(handles.Slider_excavation_depth,'Max',Max_excavation_depth);
set(handles.TXT_excavation_depth,'String',num2str(Default_excavation_depth));
%Set Min/Max values for excavation depth slider and textbox
set(handles.excavation_depth_range,'String', strcat("[", string(Min_excavation_depth), ":", string(Max_excavation_depth),"]"));

%Set default value for closing time slider and textbox
set(handles.Slider_closing_time,'Value',Default_closing_time); 
set(handles.TXT_closing_time,'String',num2str(Default_closing_time));
%Set Min/Max values for closing time slider and textbox, set Range string also
checkClosingTimeRange(hObject, eventdata, handles, Default_excavation_width);


%Set default value for oepration depth slider and textbox
set(handles.Slider_operation_depth,'Value',Default_operation_depth); 
set(handles.Slider_operation_depth,'Min',Min_operation_depth); 
set(handles.Slider_operation_depth,'Max',Max_operation_depth); 
set(handles.TXT_operation_depth,'String',num2str(Default_operation_depth));
%Set Min/Max values for oepration depth slider and textbox
set(handles.operation_depth_range,'String', strcat("[", string(Min_operation_depth), ":", string(Max_operation_depth),"]"));

%Set the window title with the group identification:
set(handles.figure1,'Name','Group DDT1 // CAD 2021');



% =========================================================================

% --- Executes on button press in BTN_Generate.
function BTN_Generate_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to BTN_Generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(isempty(handles))
    Wrong_File();
else
    
    %Get parameters from GUI
    excavation_width = str2double(get(handles.TXT_excavation_width,'String'));
    excavation_depth = str2double(get(handles.TXT_excavation_depth,'String'))/100;
    closing_time = str2double(get(handles.TXT_closing_time,'String'));
    operation_depth =  str2double(get(handles.TXT_operation_depth,'String'));
    
    %No need to check range of values here as GUI checks/corrects values as
    %they are entered
    
    %The design calculations are done within the function file Design_code.m
    Design_code(excavation_width, excavation_depth, closing_time, operation_depth); 
    
    %Show the results on the GUI.
    drive = pwd; %Get working directory drive
    drive = extractBefore(drive, "\groupDDT1");
    
    log_file = strcat(drive, '\groupDDT1\Log\groupDDT1_LOG.TXT');
    fid = fopen(log_file,'r'); %Open the log file for reading
    S=char(fread(fid)'); %Read the file into a string
    fclose(fid);

    set(handles.TXT_log,'String',S); %write the string into the textbox
    set(handles.TXT_path,'String',log_file); %show the path of the log file
    set(handles.TXT_path,'Visible','on');
end

% =========================================================================

% --- Executes on button press in BTN_Finish.
function BTN_Finish_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to BTN_Finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close gcf

% =========================================================================

% --- Gives out a message that the GUI should not be executed directly from
% the .fig file. The user should run the .m file instead.
function Wrong_File()
clc
h = msgbox('You cannot run the MAIN.fig file directly. Please run the program from the Main.m file directly.','Cannot run the figure...','error','modal');
uiwait(h);
disp('You must run the MAIN.m file. Not the MAIN.fig file.');
disp('To run the MAIN.m file, open it in the editor and press ');
disp('the green "PLAY" button, or press "F5" on the keyboard.');
close gcf

% =========================================================================
% =========================================================================
% The functions below are created by the GUI. Do not delete any of them! 
% Adding new buttons and inputs will add more callbacks and createfcns.
% =========================================================================
% =========================================================================


function TXT_log_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to TXT_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXT_log as text
%        str2double(get(hObject,'String')) returns contents of TXT_log as a double

% --- Executes during object creation, after setting all properties.
function TXT_log_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to TXT_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%DDT1
% --- Executes on slider movement.
function Slider_excavation_width_Callback(hObject, eventdata, handles)
% hObject    handle to Slider_excavation_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if(isempty(handles))
    Wrong_File();
else
    value = round(get(hObject,'Value'),1); %Round the value to 1st decimal (decameter)
    set(handles.TXT_excavation_width,'String',num2str(value)); %set text value

    
    checkClosingTimeRange(hObject, eventdata, handles, value); %calculates valid closing time range and updates sliders on GUI
    
end

% --- Executes during object creation, after setting all properties.
function Slider_excavation_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_excavation_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function TXT_excavation_width_Callback(hObject, eventdata, handles)
% hObject    handle to TXT_excavation_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXT_excavation_width as text
%        str2double(get(hObject,'String')) returns contents of TXT_excavation_width as a double

if(isempty(handles))
    Wrong_File();
else
    value = round(10*str2double(get(hObject,'String')))/10; %Get entered value, round to 1 decimal

    %Apply basic testing to see if the value does not exceed the range of the
    %slider (defined in the gui)
    if(value<get(handles.Slider_excavation_width,'Min'))
        value = get(handles.Slider_excavation_width,'Min');
    end
    if(value>get(handles.Slider_excavation_width,'Max'))
        value = get(handles.Slider_excavation_width,'Max');
    end
    set(hObject,'String',value);
    set(handles.Slider_excavation_width,'Value',value);
    
    checkClosingTimeRange(hObject, eventdata, handles, value); %adjust closing time range

end

% --- Executes during object creation, after setting all properties.
function TXT_excavation_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TXT_excavation_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function Slider_excavation_depth_Callback(hObject, eventdata, handles)
% hObject    handle to Slider_excavation_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if(isempty(handles))
    Wrong_File();
else
    value = round(get(hObject,'Value')); %Round the value to unit (cm)
    set(handles.TXT_excavation_depth,'String',num2str(value)); %set text value
    
end

% --- Executes during object creation, after setting all properties.
function Slider_excavation_depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_excavation_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%DDT1
function TXT_excavation_depth_Callback(hObject, eventdata, handles)
% hObject    handle to TXT_excavation_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXT_excavation_depth as text
%        str2double(get(hObject,'String')) returns contents of TXT_excavation_depth as a double

if(isempty(handles))
    Wrong_File();
else
    value = round(str2double(get(hObject,'String'))); %Get entered value, round to unit

    %Apply basic testing to see if the value does not exceed the range of the
    %slider (defined in the gui)
    if(value<get(handles.Slider_excavation_depth,'Min'))
        value = get(handles.Slider_excavation_depth,'Min');
    end
    if(value>get(handles.Slider_excavation_depth,'Max'))
        value = get(handles.Slider_excavation_depth,'Max');
    end
    set(hObject,'String',value);
    set(handles.Slider_excavation_depth,'Value',value);
    
end

% --- Executes during object creation, after setting all properties.
function TXT_excavation_depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TXT_excavation_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function Slider_closing_time_Callback(hObject, eventdata, handles)
% hObject    handle to Slider_closing_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if(isempty(handles))
    Wrong_File();
else
    value = round(get(hObject,'Value')); %Round the value to integer (s)
    set(handles.TXT_closing_time,'String',num2str(value)); %set text value
end


% --- Executes during object creation, after setting all properties.
function Slider_closing_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_closing_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function TXT_closing_time_Callback(hObject, eventdata, handles)
% hObject    handle to TXT_closing_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXT_closing_time as text
%        str2double(get(hObject,'String')) returns contents of TXT_closing_time as a double

if(isempty(handles))
    Wrong_File();
else
    value = round(str2double(get(hObject,'String'))); %Get entered value, round to integer (s)

    %Apply basic testing to see if the value does not exceed the range of the
    %slider (defined in the gui)
    if(value<get(handles.Slider_closing_time,'Min'))
        value = get(handles.Slider_closing_time,'Min');
    end
    if(value>get(handles.Slider_closing_time,'Max'))
        value = get(handles.Slider_closing_time,'Max');
    end
    set(hObject,'String',value);
    set(handles.Slider_closing_time,'Value',value);
end

% --- Executes during object creation, after setting all properties.
function TXT_closing_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TXT_closing_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function Slider_operation_depth_Callback(hObject, eventdata, handles)
% hObject    handle to Slider_operation_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if(isempty(handles))
    Wrong_File();
else
    value = round(get(hObject,'Value')); %Round the value to integer (m)
    set(handles.TXT_operation_depth,'String',num2str(value)); %set text value
   
end

% --- Executes during object creation, after setting all properties.
function Slider_operation_depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_operation_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function TXT_operation_depth_Callback(hObject, eventdata, handles)
% hObject    handle to TXT_operation_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXT_operation_depth as text
%        str2double(get(hObject,'String')) returns contents of TXT_operation_depth as a double


if(isempty(handles))
    Wrong_File();
else
    value = round(str2double(get(hObject,'String'))); %Get entered value, round to integer (m)

    %Apply basic testing to see if the value does not exceed the range of the
    %slider (defined in the gui)
    if(value<get(handles.Slider_operation_depth,'Min'))
        value = get(handles.Slider_operation_depth,'Min');
    end
    if(value>get(handles.Slider_operation_depth,'Max'))
        value = get(handles.Slider_operation_depth,'Max');
    end
    set(hObject,'String',value);
    set(handles.Slider_operation_depth,'Value',value);

end

% --- Executes during object creation, after setting all properties.
function TXT_operation_depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TXT_operation_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end 


function checkClosingTimeRange(hObject, eventdata, handles, bucket_width) 

[t_min,t_max] = GUIgetClosingTimeRange(bucket_width);% get range of allowable excavator closing time based on new width

%update min and max values of closing_time slider below
set(handles.Slider_closing_time,'Min',t_min);
set(handles.Slider_closing_time,'Max',t_max);

%get slider value
%check that it's in range, replace to one extreme as needed
time = get(handles.Slider_closing_time,'Value');

if(time < t_min) %if value was smaller than allowable, replace with min
    set(handles.Slider_closing_time,'Value',t_min);
    set(handles.TXT_closing_time, 'String', num2str(t_min)); %update text value
elseif (time > t_max) %if value was larger than allowable, replace with max
    set(handles.Slider_closing_time,'Value',t_max);
    set(handles.TXT_closing_time, 'String', num2str(t_max));%update text value
end

%update range String for closing time slider
set(handles.closing_time_range,'String', strcat("[", string(t_min), ":", string(t_max),"]"));
