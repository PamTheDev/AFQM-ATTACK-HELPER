if (open_delay > 0)
{
    open_delay--;
    exit;
}

if (keyboard_check_pressed(vk_escape))
{
    close_and_apply();
    exit;
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if (!mouse_check_button_pressed(mb_left))
{
    exit;
}

var close_x1 = window_x + window_w - 48;
var close_y1 = window_y + 16;
var close_x2 = close_x1 + 32;
var close_y2 = close_y1 + 32;

if (point_in_rectangle(mx, my, close_x1, close_y1, close_x2, close_y2))
{
    close_and_apply();
    exit;
}

var apply_w = 180;
var apply_h = 38;
var apply_x1 = window_x + (window_w - apply_w) * 0.5;
var apply_y1 = window_y + window_h - footer_h + 16;

if (point_in_rectangle(mx, my, apply_x1, apply_y1, apply_x1 + apply_w, apply_y1 + apply_h))
{
    close_and_apply();
    exit;
}

for (var i = 0; i < array_length(check_functions); i++)
{
    var column = floor(i / row_count);
    var row = i mod row_count;
    var option_x = window_x + 20 + column * (option_w + option_gap_x);
    var option_y = window_y + header_h + row * option_h;

    if (point_in_rectangle(mx, my, option_x, option_y, option_x + option_w, option_y + option_h - 2))
    {
        check_states[i] = !check_states[i];
        exit;
    }
}
