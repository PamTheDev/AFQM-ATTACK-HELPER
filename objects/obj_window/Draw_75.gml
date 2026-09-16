
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
draw_text_transformed(window_x + 20, window_y + 14, "Attack Connected Checks", 1.5, 1.5, 0);

var phase_label = "Phase " + string(target_phase_index);

if (is_struct(target_phase) && variable_struct_exists(target_phase, "name"))
{
    phase_label = string(target_phase.name);
}

draw_set_color(c_ltgray);
draw_text(window_x + 22, window_y + 46, phase_label + " - toggle checks that stop the attack after connecting");

var close_x1 = window_x + window_w - 48;
var close_y1 = window_y + 16;
var close_hovered = point_in_rectangle(mx, my, close_x1, close_y1, close_x1 + 32, close_y1 + 32);

draw_set_color(close_hovered ? make_color_rgb(170, 65, 65) : make_color_rgb(95, 55, 55));
draw_rectangle(close_x1, close_y1, close_x1 + 32, close_y1 + 32, false);
draw_set_color(c_white);
draw_text(close_x1 + 11, close_y1 + 7, "X");

for (var i = 0; i < array_length(check_functions); i++)
{
    var column = floor(i / row_count);
    var row = i mod row_count;
    var option_x = window_x + 20 + column * (option_w + option_gap_x);
    var option_y = window_y + header_h + row * option_h;
    var hovered = point_in_rectangle(mx, my, option_x, option_y, option_x + option_w, option_y + option_h - 2);

    draw_set_color(hovered ? make_color_rgb(62, 62, 70) : make_color_rgb(42, 42, 48));
    draw_rectangle(option_x, option_y, option_x + option_w, option_y + option_h - 2, false);

    draw_set_color(check_states[i] ? make_color_rgb(65, 175, 95) : make_color_rgb(75, 75, 82));
    draw_rectangle(
        option_x + 7,
        option_y + 6,
        option_x + 7 + checkbox_size,
        option_y + 6 + checkbox_size,
        false
    );

    draw_set_color(c_white);

    if (check_states[i])
    {
        draw_text(option_x + 12, option_y + 6, "x");
    }

    draw_text(option_x + 34, option_y + 8, check_functions[i]);
}

var apply_w = 180;
var apply_h = 38;
var apply_x1 = window_x + (window_w - apply_w) * 0.5;
var apply_y1 = window_y + window_h - footer_h + 16;
var apply_hovered = point_in_rectangle(mx, my, apply_x1, apply_y1, apply_x1 + apply_w, apply_y1 + apply_h);

draw_set_color(apply_hovered ? make_color_rgb(65, 145, 85) : make_color_rgb(45, 105, 62));
draw_rectangle(apply_x1, apply_y1, apply_x1 + apply_w, apply_y1 + apply_h, false);
draw_set_color(c_white);
draw_rectangle(apply_x1, apply_y1, apply_x1 + apply_w, apply_y1 + apply_h, true);
draw_text(apply_x1 + 39, apply_y1 + 11, "Apply & Close");

draw_set_alpha(1);
draw_set_color(c_white);
