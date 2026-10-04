mouse_over_context = false;
if ((variable_global_exists("phase_check_window_open") && global.phase_check_window_open)
    || (variable_global_exists("new_attack_window_open") && global.new_attack_window_open))
{
    scr_context_menu_close();
    exit;
}
if (!global.context_active) exit;
if (!instance_exists(global.context_owner) || keyboard_check_pressed(vk_escape))
{
    scr_context_menu_close();
    exit;
}

refresh_layout();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
mouse_over_context = point_in_rectangle(mx, my, global.context_x, global.context_y,
    global.context_x + menu_w, global.context_y + menu_height);

if (!mouse_check_button_pressed(mb_left)) exit;
if (!mouse_over_context)
{
    scr_context_menu_close();
    exit;
}
for (var i = 0; i < array_length(menu_rows); i++)
{
    var row = menu_rows[i];
    var row_top = global.context_y + row.top;
    if (my >= row_top && my < row_top + menu_h)
    {
        if (!scr_context_menu_input_enabled(row.input)) exit;
        var menu_owner = global.context_owner;
        var menu_action = row.input[$ "function"];
        scr_context_menu_close();
        method(menu_owner, menu_action)();
        exit;
    }
}
