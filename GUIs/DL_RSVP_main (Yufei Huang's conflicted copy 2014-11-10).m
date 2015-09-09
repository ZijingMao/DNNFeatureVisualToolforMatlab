function varargout = DL_RSVP_main(varargin)
%==========================================================================
% Deep Learning RSVP neural activity visualization Tool, 2014, UTSA
% This program allows dinamyc visualization of discriminant neural activity
% obtianed and generating using a Deep Learning implementation for EEG
% data.
%
% Click on Help => How to instructions for a more detailled guide about how
% to use this program
%==========================================================================



% Modification log:

%--------------------------------------------------------------------------
% ==> Version 02/25/14:
% - Added help menu, which access an instructional PDF
% - New functions created to reduce code redundancy
% - Splash image modified
% - Improvement of code organization and comments
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% ==> Version 02/24/14:
% - Brainmap update from heatmap clicks added
% - Synthetised target and non-target data adder using its new menu entry
% - Colorbar bug fixes
% - Animation generation for synthetised data added
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% ==> Version 02/21/14:
% - Minor code organization and comments added
% - non-relevant create and callback functions for GUI elements
% moved to the end of the script for easy code readng and maintenance.
% - Main GUI now displays Target and non-target activity (heatmat and
% brainplot) simultaneously using the top and botton axis respectively,
% generating animation is also activated.
% - The hidden units extraction method (on extract hidden units GUI) was
% corrected and improved
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%                       CODE LAYOUT
%    - GUI Functions
%           - Figure Initialization
%           - GUI initialization
%           - GUI CreateFcn
%           - GUI output
%
%   - Callbacks for Sub-menus
%           - Load saved result
%           - Select hidden units
%           - Generate brainplot
%           - Generate synthesised target data
%           - Generate synthesised non-target data
%           - How-to-use instructions
%
%   - CreateFcn and Callbacks for hidden units table, usage info and status
%   bar
%
%   - Generate brainmap function and clik-heatmap functionality
%
%   - Callbacks for groups of play/stop/... buttons
%
%   - Unused CreateFcn, ButtonDownFcn and callbacks for othe GUI elements
%--------------------------------------------------------------------------


%==========================================================================
%==================  GUI FUNCTIONS (CREATE/OUTPUT, ETC)  ==================
%==========================================================================


% FIGURE INITIALIZATION FUNCTION
%--------------------------------------------------------------------------
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DL_RSVP_main_OpeningFcn, ...
    'gui_OutputFcn',  @DL_RSVP_main_OutputFcn, ...
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
%--------------------------------------------------------------------------


% GUI INITIALIZATION FUNCTION
%--------------------------------------------------------------------------
% --- Executes just before DL_RSVP_main is made visible.
function DL_RSVP_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DL_RSVP_main (see VARARGIN)

% Choose default command line output for DL_RSVP_main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DL_RSVP_main wait for user response (see UIRESUME)
% uiwait(handles.figure_DL_tool_main);
%--------------------------------------------------------------------------


% GUI CREATE FUNCTION (MODIFIED)
%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function figure_DL_tool_main_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure_DL_tool_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Set the initial size of main figure
set(hObject, 'Position', [50, 50, 200, 48]);

%-------------------------- Status bar messages  -----------------------
% messages for status bar
handles.status_bar_msg{1} = 'Program started.';                  % Program justs started
handles.status_bar_msg{2} = 'Loading data, please wait...';      % About to load DL results
handles.status_bar_msg{3} = 'Loading complete.';                 % Data was loaded
handles.status_bar_msg{4} = 'Generating Brainplot animation...'; % While generating animation
handles.status_bar_msg{5} = 'Animation Completed.';               % this is the first message
handles.status_bar_msg{6} = 'Selection Completed.';
handles.status_bar_msg{7} = 'Still busy...';

% messages for usage information
handles.status_bar_msg{8} = 'File loaded: ';                  % After load file results
handles.status_bar_msg{9} = 'Methods used: ';                 % After GUI2 closes
handles.status_bar_msg{10} = 'Hidden unit: ';                 % After selecting hidden unit

% String to be updated for the usage information listbos
handles.list_limit = 50;
% Initialize lasso input flag
handles.lasso_input = 0;

% Initialize colormap matrix
handles.mycmap = set_mycmap();

guidata(hObject, handles);
%--------------------------------------------------------------------------


% GUI OUTPUT FUNCTION
%--------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = DL_RSVP_main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% disable the menus
% set(handles.menu_file_sel_hidden, 'Enable', 'off');
% set(handles.menu_brainplot_generate, 'Enable', 'off');
%--------------------------------------------------------------------------



%==========================================================================
%=======================  CALLBACKS FOR SUB-MENUS  ========================
%==========================================================================


% FILE => LOAD RESULTS CALLBACK
%--------------------------------------------------------------------------
% Call the UI control to select a .mat file, then load it and check that is
% a struct that contains Hidden, Weights, x and Y fields witht the right
% dimensions.

function menu_file_load_res_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_load_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Call the UI control to select file, store name and path on global struct
[dl_filename, dl_filepath, ~] = uigetfile({'*.mat'}, 'Select a deep learning structure.');
if isequal(dl_filename, 0) || isequal(dl_filepath, 0)
    return
end

handles.dl_filename = dl_filename;
handles.dl_filepath = dl_filepath;

% Load the selected file, get the loaded variable name and assign it to a
% generic fixed-name variable
try
    set(handles.text_status_bar, 'String', handles.status_bar_msg{2});
    pause(0.2);
    DL_saved_res = load([handles.dl_filepath, '\', handles.dl_filename]);
    set(handles.text_status_bar, 'String', handles.status_bar_msg{3});
    
    % update usage information
    update_usage_list(handles, [handles.status_bar_msg{8}, dl_filename]);
catch err
    error('MATLAB load file error.');
end
var_name = fieldnames(DL_saved_res);
instruct = char(['DL_saved_res = DL_saved_res.', var_name{1}, ';']);
eval(instruct);

% Perform the checking on the loaded struct:
% Check 1, the variable is a struct
% Check 2, the struct contain at least 4 fields named Hidden, Weigths, X, Y
% Check 3,
check_1 = isstruct(DL_saved_res);

% This is hard coded, change this later search fields on fieldname struct
check_hidden = sum(strcmp(fieldnames(DL_saved_res)', 'Hidden'));
check_weights = sum(strcmp(fieldnames(DL_saved_res)', 'Weights'));
check_chanlocs = sum(strcmp(fieldnames(DL_saved_res)', 'chanlocs'));
check_X = sum(strcmp(fieldnames(DL_saved_res)', 'X'));
check_Y = sum(strcmp(fieldnames(DL_saved_res)', 'Y'));
check_3 = (size(DL_saved_res.Hidden, 1) == size(DL_saved_res.X, 1)) && ...
    (size(DL_saved_res.Hidden, 1) == length(DL_saved_res.Y))  && ...
    (size(DL_saved_res.Hidden, 2) == size(DL_saved_res.Weights, 1)) && ...
    (size(DL_saved_res.Weights, 2) == size(DL_saved_res.X, 2));

% Check if there is lasso struct
check_lasso_struct = sum(strcmp(fieldnames(DL_saved_res)', {'FitInfo'}));
check_lasso_struct = check_lasso_struct + sum(strcmp(fieldnames(DL_saved_res)', {'B0'}));

if ( check_1 == 1 && check_hidden == 1 && check_weights == 1 && check_chanlocs == 1 && ...
        check_X == 1 && check_Y == 1 && check_3 == 1 )
    handles.verified_input = 1;
    if check_lasso_struct == 2
        handles.lasso_input = 1;
    else
        handles.lasso_input = 0;
    end
else
    handles.verified_input = 0;
    msgbox('ERROR: Please verify data structure.');
    return;
end

% Add loaded results to the main handle
handles.DL_saved_res = DL_saved_res;

% Enable menu
set(handles.menu_file_sel_hidden, 'Enable', 'on');

% Update information to the new global data struct (handles)
guidata(hObject, handles);
%--------------------------------------------------------------------------


% EDIT => SELECT HIDDEN UNITS CALLBACK
%--------------------------------------------------------------------------
% Opens a new GUI to select how to choose hidden units, then select them

function menu_file_sel_hidden_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_sel_hidden (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Call selection GUI
edit_sel_hidden_units();
% --------------------------------------------------------------------



% BRAINPLOT => GENERATE ANIMATION
% --------------------------------------------------------------------
function menu_brainplot_generate_Callback(hObject, eventdata, handles)
% hObject    handle to menu_brainplot_generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%----------------------- Generate animation ---------------------------
% Generate sequenatilly each image
step = floor(size(handles.curr_weights, 2)/24);
handles.img_num = 0;

% Put the bar - FREEZE the other GUI
h = waitbar(0,'Please wait...');

% updata the status bar
set(handles.text_status_bar, 'String', handles.status_bar_msg{4});

for id=1:step:size(handles.curr_weights, 2)
    
    % Update current image number
    handles.img_num = handles.img_num + 1;
    
    % Update filename and generate current brainmap on the background
    filename = char(['image_', num2str(handles.img_num), '.png']);
    generateBrainmap(((id-1)*1/125), handles.curr_weights, id, filename, handles);
           
    % Update the uiwait bar
    waitbar(id/size(handles.curr_weights, 2));
    
end

% close wait bar
global pflag
global pframe
pframe = 1;
pflag = 1;
%handles.play_flag = 1; % READY to play movie
guidata(hObject, handles);
close(h)


% According to target or non-target selection, make VISIBLE and ENABLE the
% correct group of buttons

if handles.target_flag == 1       % Target case
    
    % Make syn buttons Visible and Active
    changeButtonsStatus('syn', 'on', 'on', handles);
    
    % Disable real buttons
    changeButtonsStatus('real', get(handles.pushbutton_play_real, 'Visible'), 'off', handles);
    
    
elseif handles.target_flag == 0   % Non-target case
    
    % Make real buttons Visible and Active
    changeButtonsStatus('real', 'on', 'on', handles);
    
    % Disable syn buttons
    changeButtonsStatus('syn', get(handles.pushbutton_play_syn, 'Visible'), 'off', handles);
    
else                              % ERROR state
    
    
    % Disable BOTH groups of buttons on error state
    changeButtonsStatus('syn', 'on', 'off', handles);
    changeButtonsStatus('real', 'on', 'off', handles);
end

% updata the status bar
set(handles.text_status_bar, 'String', handles.status_bar_msg{5});
% --------------------------------------------------------------------


% SYNTHESIS => GENERATE TARGET DATA CALLBACK
% --------------------------------------------------------------------
function menu_synthesis_generate_target_Callback(hObject, eventdata, handles)
% hObject    handle to menu_synthesis_generate_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%=========== Make PLAY\STOP/<</>> buttons INACTIVE ========================
changeButtonsStatus('syn', get(handles.pushbutton_play_syn, 'Visible'), 'off', handles);
changeButtonsStatus('real', get(handles.pushbutton_play_real, 'Visible'), 'off', handles);

% ===================== Initial required variables ========================
handles.uitable_user_data = get(handles.uitable_hidden_units, 'UserData');
if handles.lasso_input == 1 && handles.uitable_user_data(1)/10 >= 1
    handles.discrimiative_position = find(handles.DL_saved_res.B0~=0);
else
    handles.discrimiative_position = 1:size(handles.DL_saved_res.Weights, 1);
end

user_data_W = handles.DL_saved_res.Weights(handles.discrimiative_position, :);

hidden_data = get(handles.uitable_hidden_units, 'Data');
user_data_target = zeros(size(hidden_data, 1), 1);

for idx_sel_cell = 1 : size(hidden_data, 1)
    if strcmp('Target', hidden_data{idx_sel_cell})
        user_data_target(idx_sel_cell, 1) = 1;
    else
        user_data_target(idx_sel_cell, 1) = 0;
    end
end

W_target = user_data_W(user_data_target(:, 1)==1, :);
W_nontarget = user_data_W(user_data_target(:, 1)==0, :);

% ======================= generate synthesised data =======================
user_data_hidden_value = handles.uitable_user_data(2:end);
hidden_units_size = length(user_data_hidden_value)/2;

user_data_hidden_value_target = user_data_hidden_value(1:hidden_units_size);
user_data_hidden_value_nontarget = user_data_hidden_value(hidden_units_size+1:end);

hidden_value_target = user_data_hidden_value_target(user_data_target(:, 1)==1);
hidden_value_nontarget = user_data_hidden_value_nontarget(user_data_target(:, 1)==0);

synthesised_target = hidden_value_target'*W_target;
synthesised_nontarget = hidden_value_nontarget'*W_nontarget;

handles.synthesised_target = double(reshape(synthesised_target, [68 128]));
handles.synthesised_nontarget = double(reshape(synthesised_nontarget, [68 128]));

handles.curr_weights = handles.synthesised_target;
handles.target_flag = 1;

% ======================== draw image for synthesised data ================
% Target label, create title
title_heatm = char('Heatmap of Synthesised Target activity');
title_brainm = char('Brainmap of Synthesised Target activity');

% Set up new titles
set(handles.text_title_heatmap_syn, 'String', title_heatm);
set(handles.text_title_brainmap_syn, 'String', title_brainm);
		
%------------------------------------------------------------------
% Display Heatmap and brainplot on top OR botton axis as selected

% Get maximum and minimum value of synthesised data
handles.min_val = min(min(synthesised_target), min(synthesised_nontarget));
handles.max_val = max(max(synthesised_target), max(synthesised_nontarget));

% Update brainmap handle, set up the callback for heatmap's ButtonDownFcn
handles.brainmap_handle = handles.axes_brainmap_syn;
guidata(hObject, handles);

% Plot the heat map
image_handle = imagesc(handles.synthesised_target, 'Parent', handles.axes_heatmap_syn);
set(handles.axes_heatmap_syn, 'Xcolor', [1, 1, 1]);
set(handles.axes_heatmap_syn, 'Ycolor', [1, 1, 1]);
set(handles.axes_heatmap_syn, 'XTick', [1, 16, 32, 48, 64, 80, 96, 112, 128], ...
	'XTickLabel',{'0','0.125','0.25','0.375','0.5','0.625','0.75','0.875','1 (s)'});
set(handles.axes_heatmap_syn, 'FontWeight', 'Bold');
col_pos = [0.64 0.53 0.015 0.44];
grid on
set(handles.axes_heatmap_syn, 'CLim', [handles.min_val, handles.max_val]);
caxis(handles.axes_heatmap_syn, [handles.min_val, handles.max_val])
colormap(handles.mycmap);
colorbar('peer', handles.axes_heatmap_syn, 'Position', col_pos, 'FontWeight', 'Bold');
set(image_handle, 'ButtonDownFcn', {@ImageClickCallback, handles});

% Generate brainmap for first weights sample
generateBrainmap(0, handles.synthesised_target, 1, 'first_frame.png', handles);

% Display the image on the brainplot axis
imshow([pwd, '\Temp images\', 'first_frame.png'], 'Parent', handles.brainmap_handle);

% Update flag and handles data
set(handles.menu_brainplot_generate, 'Enable', 'on');
guidata(hObject, handles);
% --------------------------------------------------------------------


% SYNTHESIS => GENERATE NON-TARGET DATA CALLBACK
% --------------------------------------------------------------------
function menu_synthesis_generate_nontarget_Callback(hObject, eventdata, handles)
% hObject    handle to menu_synthesis_generate_nontarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% =================== Both panel buttons inactive =========================
changeButtonsStatus('syn', get(handles.pushbutton_play_syn, 'Visible'), 'off', handles);
changeButtonsStatus('real', get(handles.pushbutton_play_real, 'Visible'), 'off', handles);

% ===================== Initial required variables ========================
handles.uitable_user_data = get(handles.uitable_hidden_units, 'UserData');
if handles.lasso_input == 1 && handles.uitable_user_data(1)/10 >= 1
    handles.discrimiative_position = find(handles.DL_saved_res.B0~=0);
else
    handles.discrimiative_position = 1:size(handles.DL_saved_res.Weights, 1);
end

user_data_W = handles.DL_saved_res.Weights(handles.discrimiative_position, :);

hidden_data = get(handles.uitable_hidden_units, 'Data');
user_data_target = zeros(size(hidden_data, 1), 1);

for idx_sel_cell = 1 : size(hidden_data, 1)
    if strcmp('Target', hidden_data{idx_sel_cell})
        user_data_target(idx_sel_cell, 1) = 1;
    else
        user_data_target(idx_sel_cell, 1) = 0;
    end
end

W_target = user_data_W(user_data_target(:, 1)==1, :);
W_nontarget = user_data_W(user_data_target(:, 1)==0, :);

% ======================= generate synthesised data =======================
user_data_hidden_value = handles.uitable_user_data(2:end);
hidden_units_size = length(user_data_hidden_value)/2;

user_data_hidden_value_target = user_data_hidden_value(1:hidden_units_size);
user_data_hidden_value_nontarget = user_data_hidden_value(hidden_units_size+1:end);

hidden_value_target = user_data_hidden_value_target(user_data_target(:, 1)==1);
hidden_value_nontarget = user_data_hidden_value_nontarget(user_data_target(:, 1)==0);

synthesised_target = hidden_value_target'*W_target;
synthesised_nontarget = hidden_value_nontarget'*W_nontarget;

handles.synthesised_target = double(reshape(synthesised_target, [68 128]));
handles.synthesised_nontarget = double(reshape(synthesised_nontarget, [68 128]));

handles.curr_weights = handles.synthesised_nontarget;
handles.target_flag = 0;

% ======================== draw image for synthesised data ================
% Non-target label, create title
title_heatm = char('Heatmap of Synthesised Non-target activity');
title_brainm = char('Brainmap of Synthesised Non-target activity');

% Set up new titles
set(handles.text_title_heatmap_real, 'String', title_heatm);
set(handles.text_title_brainmap_real, 'String', title_brainm);
		
%------------------------------------------------------------------
% Display Heatmap and brainplot on top OR botton axis as selected

% Get maximum and minimum value of synthesised data
handles.min_val = min(min(synthesised_target), min(synthesised_nontarget));
handles.max_val = max(max(synthesised_target), max(synthesised_nontarget));

% Update brainmap handle, set up the callback for heatmap's ButtonDownFcn
handles.brainmap_handle = handles.axes_brainmap_real;
guidata(hObject, handles);

% Plot the heat map
image_handle = imagesc(handles.synthesised_nontarget, 'Parent', handles.axes_heatmap_real);
set(handles.axes_heatmap_real, 'Xcolor', [1, 1, 1]);
set(handles.axes_heatmap_real, 'Ycolor', [1, 1, 1]);
set(handles.axes_heatmap_real, 'XTick', [1, 16, 32, 48, 64, 80, 96, 112, 128], ...
	'XTickLabel',{'0','0.125','0.25','0.375','0.5','0.625','0.75','0.875','1 (s)'});
set(handles.axes_heatmap_real, 'FontWeight', 'Bold');
col_pos = [0.64 0.03 0.015 0.44];
%delete(handles.colorbar_handle_uitable);
grid on
set(handles.axes_heatmap_real, 'CLim', [handles.min_val, handles.max_val]);
caxis(handles.axes_heatmap_real, [handles.min_val, handles.max_val])
colormap(handles.mycmap);
colorbar('peer', handles.axes_heatmap_real, 'Position', col_pos, 'FontWeight', 'Bold');
set(image_handle, 'ButtonDownFcn', {@ImageClickCallback, handles});

% Generate brainmap for first weights sample
generateBrainmap(0, handles.synthesised_nontarget, 1, 'first_frame.png', handles);

% Display the image on the brainplot axis
imshow([pwd, '\Temp images\', 'first_frame.png'], 'Parent', handles.brainmap_handle);

% Update flag and handles data
set(handles.menu_brainplot_generate, 'Enable', 'on');
guidata(hObject, handles);
% --------------------------------------------------------------------


% HELP => HOW-TO-USE CALLBACK
% --------------------------------------------------------------------
function menu_instructions_Callback(hObject, eventdata, handles)
% hObject    handle to menu_instructions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Make a system call to open the external PDF file
open('instructions.pdf');
% --------------------------------------------------------------------



%==========================================================================
%==================  UITABLE, USAGE LOG AND STATUS BAR  ===================
%==========================================================================


% HIDDEN UNITS UITABLE => CREATE FUNCTION
% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function uitable_hidden_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable_hidden_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% State of busy variable
handles.tablebusy = 0;
guidata(hObject, handles);
set(hObject, 'ColumnName', {'Hidden U. Values'});
% --------------------------------------------------------------------


% HIDDEN UNITS UITABLE => CELL SELECTION CALLBACK
% --------------------------------------------------------------------
% --- Executes when selected cell(s) is changed in uitable_hidden_units.
function uitable_hidden_units_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable_hidden_units (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Make sure the flag changes on every trigger of the vent
if handles.tablebusy == 0
    
    % set variable busy
    handles.tablebusy = 1;
    
    % Make PLAY\STOP/<</>> buttons INACTIVE
    changeButtonsStatus('syn', get(handles.pushbutton_play_syn, 'Visible'), 'off', handles);
    changeButtonsStatus('real', get(handles.pushbutton_play_real, 'Visible'), 'off', handles);
    
    if isempty(eventdata.Indices)
        return
    end
    
    %------------------------------------------------------------------
    % replace the eventdata indices to position, value/10 >= 1 means the
    % second digital is 1 which is lasso is checked
    handles.uitable_user_data = get(hObject, 'UserData');
    if handles.lasso_input == 1 && handles.uitable_user_data(1)/10 >= 1
        handles.discrimiative_position = find(handles.DL_saved_res.B0~=0);
        hidden_position = handles.discrimiative_position( eventdata.Indices(1));
    else
        handles.discrimiative_position = 1:size(handles.DL_saved_res.Weights, 1);
        hidden_position = eventdata.Indices(1);
    end
    
    % Extract the weights for the selected hidden unit
    %******************************* Make this automatic later **********
    % Reshape sizes are hard coded
    handles.curr_weights = double(reshape(handles.DL_saved_res.Weights(hidden_position, :), [68, 128]));
    
    
    %------------------------------------------------------------------
    % Determine whether the selected cell is for target or non-target and
    % raise flag
    hidden_data = get(hObject, 'Data');
    check_t = strcmp('Target', hidden_data{eventdata.Indices(1)});
    check_nt = strcmp('Nontarget', hidden_data{eventdata.Indices(1)});
    
    if ( (check_t == 1) && (check_nt ~= 1) ) % Target was selected
        
        % Update flag
        handles.target_flag = 1;
        
        % Update axis handles variables
        handles.heatmap_handle = handles.axes_heatmap_syn;
        handles.brainmap_handle = handles.axes_brainmap_syn;
        handles.col_pos = [0.64 0.53 0.015 0.44];
        
    elseif ( (check_t ~= 1) && (check_nt == 1) ) % Non-Target was selected
        
        % Update flag
        handles.target_flag = 0;
        
        % Update axis handles variables
        handles.heatmap_handle = handles.axes_heatmap_real;
        handles.brainmap_handle = handles.axes_brainmap_real;
        handles.col_pos = [0.64 0.03 0.015 0.44];
        
    else
        
        % Update flag => Error state
        handles.target_flag = -1;
        
    end
    
    %------------------------------------------------------------------
    % Create and set title for both heatmap and brainplot
    if handles.target_flag == 1
        
        % Target label and Hidden unit 1, create title
        title_heatm = char(['Heatmap of Target activity for hidden unit ', ...
            num2str(hidden_position)]);
        
        title_brainm = char(['Brainmap of Target activity for hidden unit ', num2str(hidden_position)]);
        
        % Set up new titles
        set(handles.text_title_heatmap_syn, 'String', title_heatm);
        set(handles.text_title_brainmap_syn, 'String', title_brainm);
        
    elseif handles.target_flag == 0
        
        % Target label and Hidden unit 0, create title
        title_heatm = char(['Heatmap of Non-Target activity for hidden unit ', ...
            num2str(hidden_position)]);
        
        title_brainm = char(['Brainmap of Non-Target activity for hidden unit ', num2str(hidden_position)]);
        
        % Set up new titles
        set(handles.text_title_heatmap_real, 'String', title_heatm);
        set(handles.text_title_brainmap_real, 'String', title_brainm);
        
    else
        
        % Problably there was some problem generating the label
        title_heatm = 'LABEL STRING GENERATION PROBLEM';
        title_brainm = title_heatm;
        set(handles.text_title_heatmap_real, 'String', title_heatm);
        set(handles.text_title_brainmap_real, 'String', title_brainm);
    end
    
    
    %------------------------------------------------------------------
    % Display Heatmap and brainplot on top OR botton axis as selected
    
    % Plot the heat map
    image_handle = imagesc(handles.curr_weights, 'Parent', handles.heatmap_handle);
    set(handles.heatmap_handle, 'Xcolor', [1, 1, 1]);
    set(handles.heatmap_handle, 'Ycolor', [1, 1, 1]);
    set(handles.heatmap_handle, 'XTick', [1, 16, 32, 48, 64, 80, 96, 112, 128], ...
        'XTickLabel',{'0','0.125','0.25','0.375','0.5','0.625','0.75','0.875','1 (s)'});
    set(handles.heatmap_handle, 'FontWeight', 'Bold');
    
    handles.min_val = min(min(handles.DL_saved_res.Weights));
    handles.max_val = max(max(handles.DL_saved_res.Weights));
    
    grid on
    set(handles.heatmap_handle, 'ColorOrder', handles.mycmap);
    caxis(handles.heatmap_handle, [handles.min_val, handles.max_val])
    colormap(handles.mycmap);
    set(image_handle, 'ButtonDownFcn', {@ImageClickCallback, handles});
    colorbar('peer', handles.heatmap_handle, 'Position', handles.col_pos, 'FontWeight', 'Bold');
    
    % Plot the initial brain map and make ACTIVE play buttons
    generateBrainmap(0, handles.curr_weights, 1, 'first_frame.png', handles);
       
    % Display the image on the brainplot axis
    imshow([pwd, '\Temp images\', 'first_frame.png'], 'Parent', handles.brainmap_handle);
    
    % Update the usage information list on main GUI
    update_usage_list(handles, [handles.status_bar_msg{10}, num2str(hidden_position), '.']);
    
    % update handles
    handles.tablebusy = 0;
    guidata(hObject, handles);
    
end

% Enable the menu
set(handles.menu_brainplot_generate, 'Enable', 'on');
%--------------------------------------------------------------------------


% STATUS BAR TEXT => TEXT CREATE FUNCTION
% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function text_status_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_status_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', handles.status_bar_msg{1});
%--------------------------------------------------------------------------


% USAGE LISTBOX => LISTBOX CREATE FUNCTION
%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function listbox_usage_info_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_usage_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Pre-define the string for the listbox (user data is list index)
handles.usage_listbox{1} = ['1. ', 'Welcome.'];
set(hObject, 'UserData', 2);    % set list index to 1
set(hObject, 'String', handles.usage_listbox);
guidata(hObject, handles);
%--------------------------------------------------------------------------



%==========================================================================
%==============  BRAINMAP GENERATION, CLICK FUNCTIONALITY  ================
%==========================================================================


% GENERATE BRAINMAP FUNCTION
%--------------------------------------------------------------------------
function generateBrainmap(time_var, weights_matrix, pos, filename_txt, handles)
% Create an invisible figure where a brainmap is displayed (using EEGLAB's
% topoplot function) plot is optimized and saved as an image on the 
% 'Temp images' folder (existing or a new one) using the input filename

% Declare used variables for topolot
handles.key_values{1} = 'electrodes';
handles.key_values{2} = 'off';
handles.key_values{3} = 'verbose';
handles.key_values{4} = 'off';
handles.key_values{5} = 'chaninfo';
handles.key_values{6} = struct('plotrad', {0.56}, 'shrink', {[]}, 'nosedir', ...
    {'+X'}, 'nodatchans', {[]}, 'icachansind', {[]});

% Create a brainmap (topoplot) using the input data
hfig = figure('Visible', 'off');
topoplot(weights_matrix(:, pos), handles.DL_saved_res.chanlocs, ...
    'maplimits', 'absmax', handles.key_values{:});

% Add title and color information
set(hfig, 'Color', [0.40, 0.40, 0.40]);
caxis([handles.min_val, handles.max_val]);
title([num2str(time_var, 3), ' Seconds'], 'FontSize', 20, 'Color', [1, 1, 1], 'Position', [0 -0.65]);

% Change figure properties (optimize it to be saved as image)
set(gcf, 'PaperPositionMode', 'auto')
set(gcf, 'Colormap', handles.mycmap);
set(gca,'LooseInset',get(gca,'TightInset'))
set(gcf, 'InvertHardCopy', 'off');

% Search for Temp image folder, otherwise create one
if exist([pwd, '\Temp images'], 'dir') == 0
    mkdir(pwd, '\Temp images');
end

saveas(gcf, [pwd, '\Temp images\', filename_txt]);
close(hfig);
%--------------------------------------------------------------------------


% CLICK ON HEATMAP CALLBACK => UPDATES CURRENT BRAINMAP
%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function ImageClickCallback(hObject, eventdata, handles)

%--- A heatmap was clicked, capture the X (sample) location ---
axesHandle  = get(hObject,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = coordinates(1,1:2);
handles.weights_clk_sample = floor(coordinates(1));

%--- Update the brainmap plot with the position that was just cliked ---
% Retrieve weights matrix from image handle
curr_weights = get(hObject, 'CData');


% Generate brainmap for first weights sample
generateBrainmap((((handles.weights_clk_sample-1)*1/125)), curr_weights, ...
    handles.weights_clk_sample, 'clicked_frame.png', handles);

% Display the image on the brainplot axis
imshow([pwd, '\Temp images\', 'clicked_frame.png'], 'Parent', handles.brainmap_handle);
%--------------------------------------------------------------------------




%==========================================================================
%================  TOP/BOTTOM PLAYBACK BUTTONS GROUPS  ====================
%==========================================================================


% FUNCTION TO CHANGE THE PROPERTIES OF ANY OF THE BUTTONS GROUPS
%--------------------------------------------------------------------------
function changeButtonsStatus(button_group, visible_status, enable_status, handles)
% This function allows to change the Visible and Enable status of any of
% the groups of playback buttons (syn or real)

% Check inputs =< button group
check_1 = ( (strcmp(button_group, 'syn') == 1) || (strcmp(button_group, 'real') == 1) );
check_2 = ( (strcmp(visible_status, 'on') == 1) || (strcmp(visible_status, 'off') == 1) );
check_3 = ( (strcmp(enable_status, 'on') == 1) || (strcmp(enable_status, 'off') == 1) );

% Proceed if inputs are correct
if ( check_1 && check_2 && check_3 )
    
    if (strcmp(button_group, 'syn') == 1)
        
        % Syn group was selected, change the buttons properties
        set(handles.pushbutton_play_syn, 'Visible', visible_status, 'Enable', enable_status);
        set(handles.pushbutton_stop_syn, 'Visible', visible_status, 'Enable', enable_status);
        set(handles.pushbutton_prev_frame_syn, 'Visible', visible_status, 'Enable', enable_status);
        set(handles.pushbutton_next_frame_syn, 'Visible', visible_status, 'Enable', enable_status);
           
    else
        
        % Real group was selected, change properties
        set(handles.pushbutton_play_real, 'Visible', visible_status, 'Enable', enable_status);
        set(handles.pushbutton_stop_real, 'Visible', visible_status, 'Enable', enable_status);
        set(handles.pushbutton_prev_frame_real, 'Visible', visible_status, 'Enable', enable_status);
        set(handles.pushbutton_next_frame_real, 'Visible', visible_status, 'Enable', enable_status);
        
    end
    
end


%--------------------------------------------------------------------------


% TOP/TARGET/SYN BUTTON GROUP = > PLAY BUTTON CALLBACK
%--------------------------------------------------------------------------
% --- Executes on button press in pushbutton_play_syn.
function pushbutton_play_syn_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_syn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%===================== PLAY BUTTON (Target) ====================

% Display sequentially every image
global pflag
global pframe
for id=pframe:handles.img_num
    
    pframe = id;
    
    if pflag == 0
        pflag= 1;
        guidata(hObject, handles);
        return
        
    end
    
    if pframe == handles.img_num
        pframe = 1;
    end
    
    temp_img = imread([pwd, '\Temp images\', 'image_', num2str(id), '.png']);
    imshow(temp_img, 'Parent', handles.brainmap_handle);
    pause(1/10);
    drawnow
    
end
%--------------------------------------------------------------------------


% BOTTOM/NON-TARGET/REAL BUTTON GROUP = > PLAY BUTTON CALLBACK
%--------------------------------------------------------------------------
% --- Executes on button press in pushbutton_play_real.
function pushbutton_play_real_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_play_syn_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------


% TOP/TARGET/SYN BUTTON GROUP = > STOP BUTTON CALLBACK
%--------------------------------------------------------------------------
% --- Executes on button press in pushbutton_stop_syn.
function pushbutton_stop_syn_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop_syn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%===================== STOP BUTTON (Target) ====================
global pflag
pflag = 0;
%--------------------------------------------------------------------------


% BOTTOM/NON-TARGET/REAL BUTTON GROUP = > STOP BUTTON CALLBACK
%--------------------------------------------------------------------------
% --- Executes on button press in pushbutton_stop_real.
function pushbutton_stop_real_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%===================== STOP BUTTON (Non-Target) ====================
pushbutton_stop_syn_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------


% TOP/TARGET/SYN BUTTON GROUP = > PREV. FRAME BUTTON CALLBACK
%--------------------------------------------------------------------------
% --- Executes on button press in pushbutton_prev_frame_syn.
function pushbutton_prev_frame_syn_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev_frame_syn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%===================== PREV FRAME BUTTON (Target) ====================
% Decrease frame
global pframe
if pframe ~= 1
    pframe = pframe - 1;
end

temp_img = imread([pwd, '\Temp images\', 'image_', num2str(pframe), '.png']);
imshow(temp_img, 'Parent', handles.brainmap_handle);
%--------------------------------------------------------------------------


% TOP/TARGET/SYN BUTTON GROUP = > PREV. FRAME BUTTON CALLBACK
%--------------------------------------------------------------------------
% --- Executes on button press in pushbutton_prev_frame_real.
function pushbutton_prev_frame_real_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev_frame_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%===================== PREV FRAME BUTTON (Non-Target) ====================
pushbutton_prev_frame_syn_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------


% TOP/TARGET/SYN BUTTON GROUP = > NEXT FRAME BUTTON CALLBACK
%--------------------------------------------------------------------------
% --- Executes on button press in pushbutton_next_frame_syn.
function pushbutton_next_frame_syn_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next_frame_syn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%===================== NEXT FRAME BUTTON (Target) ====================
% Increase frame
global pframe
if pframe ~= handles.img_num
    pframe = pframe + 1;
end

temp_img = imread([pwd, '\Temp images\', 'image_', num2str(pframe), '.png']);
imshow(temp_img, 'Parent', handles.brainmap_handle);
%--------------------------------------------------------------------------

% TOP/TARGET/SYN BUTTON GROUP = > NEXT FRAME BUTTON CALLBACK
%--------------------------------------------------------------------------
% --- Executes on button press in pushbutton_next_frame_real.
function pushbutton_next_frame_real_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next_frame_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%===================== NEXT FRAME BUTTON (Non-Target) ====================
pushbutton_next_frame_syn_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------




%==========================================================================
%============ UNMODIFIED/NON-RELEVANT GUI ELEMENTS FUNCTIONS ==============
%==========================================================================


%--------  HEATMAP, BRAINMAP AND COLORBAR AXIS CREATE FUNCTIONS  ----------

% --- Executes during object creation, after setting all properties.
function axes_brainmap_syn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_brainmap_syn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_brainmap_syn

axis off

% --- Executes during object creation, after setting all properties.
function axes_brainmap_real_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_brainmap_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_brainmap_real

axis off

% --- Executes during object creation, after setting all properties.
function axes_heatmap_syn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_heatmap_syn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_heatmap_syn

axis off

% --- Executes during object creation, after setting all properties.
function axes_heatmap_real_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_heatmap_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_heatmap_real
axis off

% --- Executes during object creation, after setting all properties.
function axes_colorbar2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_colorbar2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_colorbar2

axis off


%----------------  MAIN MENU ENTRIES CALLBACKS (EMPTY)  -------------------


% --------------------------------------------------------------------
function top_menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to top_menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function top_menu_edit_Callback(hObject, eventdata, handles)
% hObject    handle to top_menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function top_menu_brainplot_Callback(hObject, eventdata, handles)
% hObject    handle to top_menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function top_menu_synthesis_data_Callback(hObject, eventdata, handles)
% hObject    handle to top_menu_synthesis_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function top_menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to top_menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%--------- REMAINING BUTTONDOWN, CALLBACKS AND CREATE FUNCTIONS -----------


% --- Executes during object creation, after setting all properties.
function text_title_heatmap_syn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_title_heatmap_syn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on selection change in listbox_usage_info.
function listbox_usage_info_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_usage_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on mouse press over axes background.
function axes_heatmap_syn_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_heatmap_syn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on mouse press over axes background.
function axes_heatmap_real_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_heatmap_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function uitable_hidden_units_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uitable_hidden_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
