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
	
	draw_set_colour(c_gray)
	
	if _mouse_over {
		draw_set_colour(merge_colour(c_white, c_gray, 0.5))
	}
	
	draw_rectangle(
		start_x + i * button_s,
		start_y,
		start_x + button_w + (i * button_s),
		start_y - button_w,
		false
		);
	draw_set_colour(c_white)
	draw_text(start_x + i * button_s, start_y + 0, string(_folder_names[i]))
		
}