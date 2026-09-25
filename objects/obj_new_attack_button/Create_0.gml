parser_check_attempts = 0;
parser_check_max_attempts = 300;

window_w = 900;
window_h = 650;
header_h = 72;
footer_h = 70;

window_x = (display_get_gui_width() - window_w) * 0.5;
window_y = (display_get_gui_height() - window_h) * 0.5;



show_debug_message(string(display_get_height() / 2) + " , " + string(display_get_width() / 2))