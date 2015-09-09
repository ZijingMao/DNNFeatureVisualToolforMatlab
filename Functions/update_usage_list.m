function update_usage_list(handles, text_msg)
% Get list index
idx = get(handles.listbox_usage_info, 'UserData');

% Updte usage information
if idx > handles.list_limit
    
    % We reached the limit
    set(handles.listbox_usage_info, 'UserData', 1);

else
    
    % We have not reached the limit
    text_msg = [num2str(idx), '. ', text_msg];
    msg = get(handles.listbox_usage_info, 'String');
    msg{idx} = text_msg;
    idx = idx + 1;
    set(handles.listbox_usage_info, 'UserData', idx);
    set(handles.listbox_usage_info, 'String', msg);
    
end