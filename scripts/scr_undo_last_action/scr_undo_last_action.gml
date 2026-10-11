function scr_undo_last_action()
{
    if (!variable_global_exists("undo_history"))
    {
        global.undo_history = [];
        return;
    }

    var count = array_length(global.undo_history);

    if (count <= 0)
    {
        show_debug_message("Nothing to undo.");
        return;
    }

    var action = global.undo_history[count - 1];

    array_delete(global.undo_history, count - 1, 1);

    global.history_restoring = true;
    action.redo_state = scr_context_capture_timeline();
    if (!variable_global_exists("redo_history")) global.redo_history = [];
    array_push(global.redo_history, action);
    if (action.type == "context_edit") scr_context_restore_timeline(action.before);
    else if (action.type == "hitbox_transform")
    {
        scr_apply_hitbox_state(action.target, action.before);

        show_debug_message("Undid hitbox transform.");
    }
    else if (action.type == "timeline_key_timing")
    {
        scr_apply_timeline_key_state(action.target, action.before);

        if (variable_global_exists("timeline"))
        {
            scr_sort_all_timeline_tracks(global.timeline);
            scr_recalculate_timeline_total_frames(global.timeline);

            global.current_timeline_frame = clamp(
                action.before.start,
                0,
                max(0, global.timeline.total_frames - 1)
            );
        }

        show_debug_message("Undid timeline key timing.");
    }
	else if (action.type == "track_added")
	{
		array_delete(global.timeline.tracks, action.target, 1); 
        show_debug_message("Undid track addition.");
	}
		else if (action.type == "timeline_key_edit")
	{
    // Move the key back to the original track first.
		if (action.from_track != action.to_track)
		{
			scr_move_timeline_key_to_track(
				global.timeline,
				action.target,
				action.to_track,
				action.from_track
			);
		}

    // Restore old start/duration.
		scr_apply_timeline_key_state(action.target, action.before);

		scr_sort_all_timeline_tracks(global.timeline);
		scr_recalculate_timeline_total_frames(global.timeline);

		global.current_timeline_frame = clamp(
			action.before.start,
			0,
			max(0, global.timeline.total_frames - 1)
		);

		show_debug_message("Undid timeline key edit.");
	} else if (action.type == "phase_attack_connected_checks")
{
    scr_set_phase_flags_code(action.target, action.before, "code");

    mark_attack_json_dirty();
    scr_save_current_attack_json();

    show_debug_message("Undid attack-connected check changes.");
}
	else if (action.type == "phase_attack_stop_state")
{
    scr_set_phase_attack_stop_state(action.target, action.before);

    mark_attack_json_dirty();
    scr_save_current_attack_json();

    show_debug_message("Undid phase end state change.");
}
	else if (action.type == "hitbox_property_edit")
{
    scr_text_input_write_target_value(
        action.input_id,
        action.target,
        action.before
    );

    if (variable_global_exists("timeline"))
    {
        if (!is_undefined(global.timeline))
        {
            scr_sort_all_timeline_tracks(global.timeline);
            scr_recalculate_timeline_total_frames(global.timeline);
            scr_timeline_refresh_phase_indices(global.timeline);
        }
    }

    mark_attack_json_dirty();
    scr_save_current_attack_json();

    show_debug_message("Undid hitbox property edit:");
    show_debug_message(action.property);
}
    if (action.type != "context_edit")
    {
        scr_sort_all_timeline_tracks(global.timeline);
        scr_recalculate_timeline_total_frames(global.timeline);
        scr_timeline_refresh_phase_indices(global.timeline);
        mark_attack_json_dirty();
        scr_save_current_attack_json();
    }
    global.history_restoring = false;
}
