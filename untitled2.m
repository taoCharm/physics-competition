function varargout = untitled2(varargin)

% UNTITLED2 MATLAB code for untitled2.fig
%      UNTITLED2, by itself, creates a new UNTITLED2 or raises the existing
%      singleton*.
%
%      H = UNTITLED2 returns the handle to a new UNTITLED2 or the handle to
%      the existing singleton*.
%
%      UNTITLED2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED2.M with the given input arguments.
%
%      UNTITLED2('Property','Value',...) creates a new UNTITLED2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled2

% Last Modified by GUIDE v2.5 23-Aug-2021 15:28:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled2_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled2_OutputFcn, ...
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

% --- Executes just before untitled2 is made visible.
function untitled2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled2 (see VARARGIN)

% Choose default command line output for untitled2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using untitled2.
if strcmp(get(hObject,'Visible'),'off')
    plot(membrane);
end

% UIWAIT makes untitled2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');

switch popup_sel_index
    case 1
        figure(1);
        % calculate the magnus coefficient
        rad_label = handles.radString_label;    % call the data we saved in guidata object
        x_label = handles.x_label;     
        y_label = handles.y_label;
        z_label = handles.z_label;
        
        % data may be used
        radiusOfBall = 20 * 10^(-3);
        mOfBall = 2.7 * 10^(-3);
        densityOfBall = mOfBall/(4/3 * pi * radiusOfBall^3);
        kOfAir = 0.00153;
        density = 2.7;
        
        % calculate the force from the air
        G_from_air = kOfAir * (x_label^2+y_label^2)^0.6;       % k * v^(1.2)
        
        kOfMagnus = (4/3) * 4 * pi^2 * radiusOfBall^3 * rad_label * density * (x_label^2+y_label^2);
        G = G_from_air*10^-2; k = kOfMagnus*10^-6; m = mOfBall;     % G: drag coefficient  k: Magnus coefficient 
        disp(k);
        disp(G);
        tspan = [0:0.001:2];    % integral time and step
        
        y0 = [0,x_label,0,y_label,0,z_label];     % initial conditions
        y_stable_0 = [0,x_label,0,y_label,0,z_label]; % initial conditions when pingpong is not in rotating
        [t,y] = ode23(@(t,y)pingpong(t,y,k,G,m),tspan,y0);  % calculate the differential equation by ode23 method, which is faster than ode45
        [t_stable,y_stable] = ode23(@(t_stable,y_stable)pingpong_stable(t_stable,y_stable,k,G,m),tspan,y_stable_0);
        
        % culculate the height of the ball
        
        table_tennis_net_height = 2.5;   %CAN'T CHANGE
        table_height = 2;  % CAN'T CHANGE
        logInFigureNet = '';
        logInFigureTable = '';
        n = length(t);
        rootWant = 998;   % it can be any number as long as you like it 
        
        % Fit the equation of trajectory projection curve, which is
        % different from following 'case'. The destribution here is to make
        % sure that if the ball is 'legal'.
        x_pingpong = y(:,1);
        y_pingpong = y(:,3);
        p = polyfit(x_pingpong,y_pingpong,2);   % gain the equation here
        
        % It is important to operate the equation so that we can gain the
        % real root
        root = roots([p(1) p(2)+1 p(3)-25]);
        
        % to gain the real root of the equation
        for i = 1:2     %Two solutions to a quadratic equation with one variable
            if root(i)>=10 & root(i) <=15 
                rootWant = root(i);
            end
        end
        
         
        for i = 1:n
            if y(i,1) >= rootWant & y(i-1,1)<= rootWant

                % 1, 3, 5 column is the position x, y, z of the ball
                
                first_height_will_solve = y(i,5);
                second_height_will_solve = y(i-1,5);
                height_pingpong = 0.5*first_height_will_solve + 0.5*second_height_will_solve;
                
                if height_pingpong > table_tennis_net_height
                    logInFigureNet = "成功过网";
                elseif height_pingpong == table_tennis_net_height
                    logInFigureNet = "擦网球！";  
                else
                    logInFigureNet = '没过网';
               
                end
            
            else
                logInFigureTable = '乒乓球没有成功上台，可以尝试修改初速度';
             
            end
            
        for i_height = 2:n
            if y(i_height,5)<table_height & y(i_height-1,5)>table_height      % can't write as i，i+1（i+1 will out of index），can't i-1，i neither（i-1 will be 0）
                disp(y(i_height,5));
                disp(y(i_height-1,5));
                disp(y(i_height,1));
                disp(y(i_height,3));
                if -5<=-y(i_height,1)+y(i_height,3) & -y(i_height,1)+y(i_height,3)<=5 & 15<=y(i_height,3)+y(i_height,1) & y(i_height,3)y(i_height,1)<=35

                    logInFigureTable = '乒乓球成功上台';
                else
                    logInFigureTable = '乒乓球没有成功上台，可以尝试修改初速度';

                end  
                break;

            elseif i_height == n             % no point is fit
                logInFigureTable = '乒乓球没有成功上台，可以尝试修改初速度';

            end
        end
            
        end    
        
        
        % draw the pingpong table plat which is BLUE
        A=[15;20;2];
        B=[10;5;2];
        C=[5;10;2];
        D=[20;15;2];
        P = [B,D;C,A];
        X = P([1,4],:);
        Y = P([2,5],:);
        Z = P([3,6],:);
        h = surf(X,Y,Z);
        set(h,'FaceColor','b'); 
        
        % draw the table details
        line([15,20],[20,15],[2,2],'color','b','linestyle','-','linewidth',3);
        line([10,5],[5,10],[2,2],'color','b','linestyle','-','linewidth',3);
        line([15,5],[20,10],[2,2],'color','b','linestyle','-','linewidth',3);
        line([20,10],[15,5],[2,2],'color','b','linestyle','-','linewidth',3);
        line([15,15],[10,10],[2,2.5],'color','r','linestyle','-','linewidth',1);
        
        % net on table 
        line([10,10],[15,15],[2,2.5],'color','r','linestyle','-','linewidth',1);
        line([15,10],[10,15],[2.5,2.5],'color','r','linestyle','-','linewidth',1);
        line([17.5,7.5],[17.5,7.5],[2,2],'color','w','linestyle','-','linewidth',1);
        
        % table leg
        line([11,11],[6,6],[2,0],'color','k','linestyle','-','linewidth',6);
        line([6,6],[11,11],[2,0],'color','k','linestyle','-','linewidth',6);
        line([14,14],[19,19],[2,0],'color','k','linestyle','-','linewidth',6);
        line([19,19],[14,14],[2,0],'color','k','linestyle','-','linewidth',6);
        hold on;
        
        % draw the track of the ball
        plot3(y(:,1),y(:,3),y(:,5),'linestyle','-','linewidth',2);  % rotating
        plot3(y_stable(:,1),y_stable(:,3),y_stable(:,5),'linestyle','-.','linewidth',0.8);  % not rotating
        hold off;  
        view(-40,60);
        grid on
        
        % an important step, in which I change the distance of the axis, it
        % means that the plot will be more logical
        title('乒乓球轨迹','fontsize',16);axis([0,25,0,25,0,5]);
       
        xlabel('x/m','FontSize',16); 
        ylabel('y/m','FontSize',16);
        zlabel('z/m','FontSize',16);
        
        text(20, 20, 4, logInFigureNet);
        text(20, 20, 4.5, logInFigureTable);
        
        % I consult the code in <College Physics> which was wrote by
        % Yongsheng Han, who is my physics teacher last year. He used
        % 'line' function and 'erasemode' property in his work. However,
        % the erasemode has not been supported since matlab r2014a. Because
        % Mr. Han is old. So he used something which is out of date. In this
        % part, I change "erasemode" to "animatedline", which is better
        % nowadays and the official website of matlab also recommends us to use this method.
        
        h = animatedline('MarkerSize', 30, 'MarkerFaceColor', 'cyan', 'marker', '.');
        x_ball = y(1:end,1);
        y_ball = y(1:end,3);
        z_ball = y(1:end,5);
        start_timer = tic;
        
        for k = 1:length(x_ball)
            addpoints(h,x_ball(k),y_ball(k),z_ball(k));
            b = toc(start_timer); % check timer
            % the less denominator is, the more frequently figure upgrades
            if b > (1/300)
                drawnow; % update screen every 1/1000 seconds
                start_timer = tic; % reset timer after updating

            end
            % To provide draw a thick line which is unrealistic
            clearpoints(h);
            % clearpoints(h) clears all points from the animated line specified by h. 
            % Create an animated line with the animatedline function. 
            % If you want to display the update on the screen, use drawnow after using clearpoints. 
            % (from documentation of matlab)
        end
        drawnow;
        
    case 2
        rad_label = handles.radString_label;    % call the data we saved in guidata object
        x_label = handles.x_label;     
        y_label = handles.y_label;
        z_label = handles.z_label;
        
        % data may be used
        radiusOfBall = 20 * 10^(-3);
        mOfBall = 2.7 * 10^(-3);
        densityOfBall = mOfBall/(4/3 * pi * radiusOfBall^3);  
        kOfAir = 0.00153;
        density = 2.7;    
        
        % calculate the force from the air
        G_from_air = kOfAir * (x_label^2+y_label^2+z_label)^0.6;
        
        kOfMagnus = (4/3) * 4 * pi^2 * radiusOfBall^3 * rad_label * density * (x_label^2+y_label^2);
        G = G_from_air*10^-2; k = kOfMagnus*10^-6; m = mOfBall;     % G: drag coefficient  k: Magnus coefficient 
        tspan = [0:0.001:2];    % integral time and step
        y0 = [0,x_label,0,y_label,0,z_label];     % initial conditions
        y_stable_0 = [0,x_label,0,y_label,0,z_label];  % initial conditions when pingpong is not in rotating
        [t,y] = ode23(@(t,y)pingpong(t,y,k,G,m),tspan,y0);  %calculate the differential equation by ode23 method, which is faster than ode45
        [t_stable,y_stable] = ode23(@(t_stable,y_stable)pingpong_stable(t_stable,y_stable,k,G,m),tspan,y_stable_0);
        
        
        % Fit the equation of trajectory projection curve
        x_pingpong = y(:,1);
        y_pingpong = y(:,3);
        disp(x_pingpong);
        disp(y_pingpong);
        
        plot(x_pingpong, y_pingpong, '*');
        p = polyfit(x_pingpong,y_pingpong,2);
        str_equation = sprintf('$$equation: y=%fx^2 + %fx + %f$$', p(1), p(2), p(3));  % useless, in order to make the program faster 
        line([10,15],[15,10],'color','r', 'linestyle', '-.', 'linewidth', 2);
        text(3.25,20.5,str_equation,'Interpreter','latex');
        text(3.25,18.5,'红线为乒乓球网投影','Interpreter','latex');
        axis([0,25,0,21]);  % Set the range of axis, in this way the text will be shown on a fixed position
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'绘制乒乓球飞行图像', '绘制乒乓球投影图像'});



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
text_inside = get(hObject,'String');
handles.x_label = str2double(text_inside);   % build a value inside handles object
guidata(hObject,handles);                     % save the value which was built just now to the guidata

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ydot = pingpong(~,y,k,G,m)
ydot = [
    y(2);
    -(k/m)*y(2).^2-(G/m)*y(2);
    y(4);
    -(k/m)*y(4).^2+(G/m)*y(4);
    y(6);
    -9.8
    ];

% --------------------------------------------------------------------------
function ydot2 = pingpong_stable(~,y_stable,~,~,~)
ydot2 = [
    y_stable(2);
    0;
    y_stable(4);
    0;
    y_stable(6);
    -9.8
    ];



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
text_inside_y = get(hObject,'String');
handles.y_label = str2double(text_inside_y);   % build a value inside handles object
guidata(hObject,handles);                     % save the value which was built just now to the guidata
% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
text_inside_z = get(hObject,'String');
handles.z_label = str2double(text_inside_z);   % build a value inside handles object
guidata(hObject,handles);                     % save the value which was built just now to the guidata
% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
radString = get(hObject,'String');
handles.radString_label = str2double(radString);   % build a value inside handles object
guidata(hObject,handles);                     % save the value which was built just now to the guidata
% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
