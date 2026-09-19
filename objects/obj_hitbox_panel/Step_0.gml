timeline = global.timeline;

if (!variable_global_exists("phase_check_window_reopen_block"))
{
    global.phase_check_window_reopen_block = 0;
}
else if (global.phase_check_window_reopen_block > 0)
{
    global.phase_check_window_reopen_block--;
}

if (
    variable_global_exists("menu_focus") &&
    global.menu_focus == "phase" &&
    variable_global_exists("selected_phase_index") &&
    global.selected_phase_index >= 0
)
{
    var button_x1 = panel_x + 20;
    var button_y1 = panel_y + 95;
    var button_x2 = button_x1 + 420;
    var button_y2 = button_y1 + 42;
    var end_state_y1 = panel_y + 150;
    var end_state_y2 = end_state_y1 + 42;
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var window_is_open = instance_exists(obj_window);

    if (variable_global_exists("phase_check_window_open"))
    {
        window_is_open = window_is_open || global.phase_check_window_open;
    }

    window_is_open = window_is_open || global.phase_check_window_reopen_block > 0;

    if (!window_is_open && mouse_check_button_pressed(mb_left))
    {
        var requested_window_mode = "";

        if (point_in_rectangle(mx, my, button_x1, button_y1, button_x2, button_y2))
        {
            requested_window_mode = "attack_connected";
        }
        else if (point_in_rectangle(mx, my, button_x1, end_state_y1, button_x2, end_state_y2))
        {
            requested_window_mode = "attack_stop";
        }

        if (requested_window_mode != "")
        {
            scr_clear_text_input_focus();

            global.phase_window_mode = requested_window_mode;
            global.phase_check_target_phase = scr_get_selected_phase();
            global.phase_check_target_phase_index = global.selected_phase_index;

            instance_create_layer(0, 0, "Instances", obj_window);
        }
    }
}
