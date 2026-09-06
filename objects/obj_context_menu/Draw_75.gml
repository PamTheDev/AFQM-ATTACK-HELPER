var cx = global.context_x
var cy = global.context_y


function draw_option_box(_by){
	draw_rectangle(
	global.context_x, 
	global.context_y + _by, 
	global.context_x + menu_w, 
	global.context_y + _by + menu_h, 
	false
	);
}

var mx = device_mouse_x_to_gui(0)
var my = device_mouse_y_to_gui(0)
var full_menu_h =  menu_h * array_length(global.context_items)

if !global.context_active
	exit;

draw_set_color(c_black);
draw_set_alpha(0.25)
draw_rectangle(
	global.context_x - 10, 
	global.context_y - 10, 
	global.context_x + menu_w + 10, 
	global.context_y + full_menu_h + 10, 
	false);
	
draw_set_alpha(1)

for (var i = 0; i < array_length(global.context_items); i++){
	var _color = merge_colour(c_gray, c_dkgray, 0.5)
	
	var mouse_over_option =
		mx >= cx &&
		mx <= cx + menu_w &&
		my >= cy + (menu_h * i) &&
		my <= cy + (menu_h * i) + menu_h;
	
	if mouse_over_option
		draw_set_color(c_gray);
	else
		draw_set_color(_color);
	
	draw_option_box(menu_h * i);
	draw_set_color(c_white);
	draw_text_ext_transformed(cx + 8, cy + (menu_h * i) + 7, global.context_items[i], 2, menu_w, 1, 1, 0);
}

draw_set_color(c_white);
draw_rectangle(
	global.context_x, 
	global.context_y, 
	global.context_x + menu_w, 
	global.context_y + full_menu_h, 
	true);
