var _dcx = display_get_width() / 2;
var _dcy = display_get_height() / 2;

draw_set_colour(c_ltgray)
draw_rectangle(
	_dcx + window_width / 2, 
	_dcy - window_height / 2, 
	_dcx , 
	_dcy , 
	false);
