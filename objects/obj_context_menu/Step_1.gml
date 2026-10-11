global.context_click_consumed = false;
if (mouse_check_button_pressed(mb_right) && instance_exists(obj_timeline)
    && !(variable_global_exists("phase_check_window_open") && global.phase_check_window_open)
    && !(variable_global_exists("new_attack_window_open") && global.new_attack_window_open))
{
    scr_clear_text_input_focus();
    scr_context_menu_open("attack", instance_find(obj_timeline, 0));
}
if (!global.context_active) exit;
refresh_layout();
// Consume the dismissing click too, to avoid editing underneath an open menu.
global.context_click_consumed = mouse_check_button_pressed(mb_left);
