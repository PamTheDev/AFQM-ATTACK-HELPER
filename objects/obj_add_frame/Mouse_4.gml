if (variable_global_exists("phase_check_window_open") && global.phase_check_window_open) exit;

switch (image_index)
{
	case 0:
		scr_add_animation_frame_at_playhead(global.timeline, 0)
		break;
	case 1:
		scr_add_flag_at_playhead(global.timeline)
}
