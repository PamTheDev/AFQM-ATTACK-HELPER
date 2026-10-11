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
mouse_over_context = context_contains_mouse();
for (var i = 0; i < array_length(menu_rows); i++)
{
    var row = menu_rows[i];
    if (!point_in_rectangle(mx, my, row.x, row.y, row.x + menu_w, row.y + menu_h)) continue;
    if (variable_struct_exists(row.input, "children"))
    {
        global.context_submenu = row.index;
        exit;
    }
    if (!row.child && global.context_submenu != -1)
    {
        global.context_submenu = -1;
        refresh_layout();
    }
    if (!mouse_check_button_pressed(mb_left) || !scr_context_menu_input_enabled(row.input)) exit;
    var action = row.input[$ "function"];
    var owner = global.context_owner;
    var bound_action = row.input.bound_action;
    scr_context_menu_close();
    if (bound_action) action();
    else method(owner, action)();
    exit;
}
if (mouse_check_button_pressed(mb_left)) scr_context_menu_close();
