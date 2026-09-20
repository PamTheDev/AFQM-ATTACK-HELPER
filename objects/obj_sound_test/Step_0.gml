var start_x = x;
var start_y = y;

var button_w = 125;
var button_s = button_w + 30;

var mx = device_mouse_x_to_gui(0)
var my = device_mouse_y_to_gui(0)

var _folder_names = variable_struct_get_names(folders_list);

for (var i = 0; i < array_length(_folder_names); i++){
	
	var _mouse_over = (
		mx >= start_x + i * button_s &&
		mx <= start_x + button_w + (i * button_s) &&
		my <= start_y &&
		my >= start_y - button_w
		);
	
	
	if _mouse_over {
		if mouse_check_button_pressed(1)
		{
			selected_folder = _folder_names[i]
			show_debug_message(string(selected_folder))
		}
	}
}