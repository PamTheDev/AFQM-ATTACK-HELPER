if (variable_global_exists("context_click_consumed") && global.context_click_consumed) exit;

if (variable_global_exists("phase_check_window_open") && global.phase_check_window_open) exit;

if (global.hitbox_creation_state = "")
{
	global.hitbox_creation_state = "start"
	global.hitbox_creation_type = hitbox_type
}
