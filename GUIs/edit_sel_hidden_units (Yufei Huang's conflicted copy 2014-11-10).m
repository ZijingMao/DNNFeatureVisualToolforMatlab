function varargout = edit_sel_hidden_units(varargin)
% EDIT_SEL_HIDDEN_UNITS MATLAB code for edit_sel_hidden_units.fig
%      EDIT_SEL_HIDDEN_UNITS, by itself, creates a new EDIT_SEL_HIDDEN_UNITS or raises the existing
%      singleton*.
%
%      H = EDIT_SEL_HIDDEN_UNITS returns the handle to a new EDIT_SEL_HIDDEN_UNITS or the handle to
%      the existing singleton*.
%
%      EDIT_SEL_HIDDEN_UNITS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDIT_SEL_HIDDEN_UNITS.M with the given input arguments.
%
%      EDIT_SEL_HIDDEN_UNITS('Property','Value',...) creates a new EDIT_SEL_HIDDEN_UNITS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before edit_sel_hidden_units_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to edit_sel_hidden_units_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help edit_sel_hidden_units

% Last Modified by GUIDE v2.5 21-Mar-2014 14:17:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @edit_sel_hidden_units_OpeningFcn, ...
    'gui_OutputFcn',  @edit_sel_hidden_units_OutputFcn, ...
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


% --- Executes just before edit_sel_hidden_units is made visible.
function edit_sel_hidden_units_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to edit_sel_hidden_units (see VARARGIN)

% Choose default command line output for edit_sel_hidden_units
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes edit_sel_hidden_units wait for user response (see UIRESUME)
% uiwait(handles.figure_edit_sel_hidden_uints);


% --- Outputs from this function are returned to the command line.
function varargout = edit_sel_hidden_units_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.output);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_hidden_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_hidden_num as text
%        str2double(get(hObject,'String')) returns contents of edit_hidden_num as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_hidden_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%set(handles.edit_hidden_num, 'Enable', 'off');



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
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


% --- Executes on button press in pushbutton_sel_hidden.
function pushbutton_sel_hidden_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sel_hidden (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%---------------- Get input from user, extract hidden units ---------------
sel_choice = handles.selection;
label_choice = get(handles.popupmenu1);
label_choice = label_choice.Value;
main_GUI_data = guidata(DL_RSVP_main);
Y = main_GUI_data.DL_saved_res.Y;

if strcmp(sel_choice, 'Mean')
    
    if label_choice ~= 1
        hidden_sel = mean(main_GUI_data.DL_saved_res.Hidden(Y==3-label_choice, :));
    else
        hidden_sel_target = mean(main_GUI_data.DL_saved_res.Hidden(Y==1, :));
        hidden_sel_nontarget = mean(main_GUI_data.DL_saved_res.Hidden(Y==0, :));
        hidden_sel = single(hidden_sel_target>hidden_sel_nontarget);
    end
    
elseif strcmp(sel_choice, 'Median')
    
    if label_choice ~= 1
        hidden_sel = median(main_GUI_data.DL_saved_res.Hidden(Y==3-label_choice, :));
    else
        hidden_sel_target = median(main_GUI_data.DL_saved_res.Hidden(Y==1, :));
        hidden_sel_nontarget = median(main_GUI_data.DL_saved_res.Hidden(Y==0, :));
        hidden_sel = single(hidden_sel_target>hidden_sel_nontarget);
    end
    
else
    
    % Input case, check input
    edit_number = get(handles.edit_hidden_num);
    method_val = str2double(edit_number.String);
    if isnan(method_val) || isempty(method_val) || method_val > size(main_GUI_data.DL_saved_res.Hidden, 1)
       h = msgbox('Please Type a valid number.');
       InterfaceObj=findobj(handles.figure_edit_sel_hidden_uints,'Enable','on');
       set(InterfaceObj,'Enable','off');
       uiwait(h);
       set(InterfaceObj,'Enable','on');
       return
    end
    
    % If target data sample is selected, then hidden_sel = 1 means target
    % related activity and hidden_sel = 0 means non-target related activity
    % This is new condition requires add in
    hidden_sel = main_GUI_data.DL_saved_res.Hidden(method_val, :);
    
end

% If lasso is checked
if handles.lasso_flag == 1
    hidden_sel = hidden_sel(1, main_GUI_data.DL_saved_res.B0 ~= 0);
    % Update the row index of uitable
    discriminate_hidden = find(main_GUI_data.DL_saved_res.B0 ~= 0);
    set(main_GUI_data.uitable_hidden_units, 'RowName', {discriminate_hidden});
else
    set(main_GUI_data.uitable_hidden_units, 'RowName', {1:length(hidden_sel)});
end

%------------ Show hidden units on main GUI, update status bar ------------

% Display values, and make uitable visible

% Set threshold for hidden units, set a threshold based on the distribution
% of hidden units will not seperate hidden units apart from target and
% non-target, so we just compare the value of hidden units to see which one
% is larger when you select both.
hidden_sel( hidden_sel >= 0.3 ) = 1;
hidden_sel( hidden_sel < 0.3 ) = 0;

% if the label choice is non-target then hidden selection is equal
% to 1-hidden_selection to make hidden value of target to 1
if label_choice == 3
    hidden_sel = 1 - hidden_sel;
end

hidden_sel_cell = cell(size(hidden_sel, 2), 1);
for idx_sel_cell = 1 : size(hidden_sel, 2)
    if hidden_sel(idx_sel_cell)==1
        hidden_sel_cell{idx_sel_cell, 1} = 'Target';
    else
        hidden_sel_cell{idx_sel_cell, 1} = 'Nontarget';
    end
end

set(main_GUI_data.uitable_hidden_units, 'Data', hidden_sel_cell, 'Visible', 'on');

% Update the status bar on main GUI
set(main_GUI_data.text_status_bar, 'String', main_GUI_data.status_bar_msg{6});

% Update the usage information list on main GUI
switch label_choice
    case 1
        lbl_choice = 'Both';
    case 2
        lbl_choice = 'Target';
    case 3
        lbl_choice = 'Non-target';
    otherwise
        lbl_choice = get(handles.edit_hidden_num, 'String');
end
        
update_usage_list(main_GUI_data, [main_GUI_data.status_bar_msg{9}, sel_choice, ', ', lbl_choice, '.']);

% Unused code for updating status of target and nontarget flags but the
% code will be useful to update lasso flag
% update the label will be used for brainmap and heatmap
label_Ntarget = strfind(lbl_choice, 'Non');

% set lasso checked flag on label_Ntarget
if handles.lasso_flag == 1
    if ~isempty(label_Ntarget)
        label_Ntarget = 10;
    else
        label_Ntarget = 11;
    end
else
    if ~isempty(label_Ntarget)
        label_Ntarget = 00;
    else
        label_Ntarget = 01;
    end
end

% Append information of value of target and nontarget hidden units
label_Ntarget = [label_Ntarget; hidden_sel_target'; hidden_sel_nontarget'];
set(main_GUI_data.uitable_hidden_units, 'UserData', label_Ntarget);
set(main_GUI_data.menu_synthesis_generate_target, 'Enable', 'on');
set(main_GUI_data.menu_synthesis_generate_nontarget, 'Enable', 'on');

close(handles.figure_edit_sel_hidden_uints);


% --- Executes during object creation, after setting all properties.
function ui_panel_sel_hidden_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ui_panel_sel_hidden (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.selection = 'Mean';
guidata(hObject, handles);


% --- Executes when selected object is changed in ui_panel_sel_hidden.
function ui_panel_sel_hidden_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ui_panel_sel_hidden
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

sel_choice = get(hObject);
sel_choice = sel_choice.String;
handles.selection = sel_choice;

if strcmp(sel_choice, 'Input')
    
    set(handles.edit_hidden_num, 'Enable', 'on');
    set(handles.popupmenu1, 'Enable', 'off');
else
    set(handles.edit_hidden_num, 'Enable', 'off');
    set(handles.popupmenu1, 'Enable', 'on');
end

guidata(hObject, handles);



function edit_hidden_num_Callback(hObject, eventdata, handles)
% hObject    handle to edit_hidden_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_hidden_num as text
%        str2double(get(hObject,'String')) returns contents of edit_hidden_num as a double


% --- Executes during object creation, after setting all properties.
function edit_hidden_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_hidden_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_lasso_method.
function checkbox_lasso_method_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_lasso_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_lasso_method
% Implement lasso selection method here
handles.lasso_flag = get(hObject, 'value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function figure_edit_sel_hidden_uints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure_edit_sel_hidden_uints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.lasso_flag = 0;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function checkbox_lasso_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_lasso_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
main_GUI_data = guidata(DL_RSVP_main);
lasso_input = main_GUI_data.lasso_input;
if lasso_input == 1
    set(hObject, 'Enable', 'on');
else
    set(hObject, 'Enable', 'off');
end

guidata(hObject, handles);
