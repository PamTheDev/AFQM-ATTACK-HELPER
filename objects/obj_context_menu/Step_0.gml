if (variable_global_exists("phase_check_window_open") && global.phase_check_window_open)
{
    global.context_active = false;
    exit;
}

if (variable_global_exists("phase_check_window_open") && global.phase_check_window_open)
{
    global.context_active = false;
    exit;
}

var mx = device_mouse_x_to_gui(0)
var my = device_mouse_y_to_gui(0)
	
var full_menu_h =  menu_h * array_length(global.context_items)

mouse_over_context =
	mx >= global.context_x && 
	my >= global.context_y && 
	mx <= global.context_x + menu_w && 
	my <= global.context_y + full_menu_h;
		
if (mouse_check_button_pressed(mb_right)) {
	global.context_x = mx
	global.context_y = my
	global.context_active = true
}

if (global.context_active && !mouse_over_context) {
	if mouse_check_button_pressed(mb_left)
		global.context_active = false
}
