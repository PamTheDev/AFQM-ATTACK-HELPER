
/*
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

draw_set_alpha(0.70);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

draw_set_color(make_color_rgb(28, 28, 32));
draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, false);

draw_set_color(make_color_rgb(68, 68, 76));
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h - 8, false);

draw_set_color(c_white);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, true);