show_debug_message("Alarm 0 running.");

parser_check_attempts += 1;

show_debug_message("Checking for JSON:");
show_debug_message(global.pending_json_path);

if (file_exists(global.pending_json_path))
{
    show_debug_message("Parser finished. JSON created:");
    show_debug_message(global.pending_json_path);

    global.current_attack_json_path = global.pending_json_path;

    global.current_attack_data = scr_load_json_file(global.current_attack_json_path);
	
	global.attack_json_dirty = false;
	
    if (is_undefined(global.current_attack_data))
    {
        show_debug_message("ERROR: Failed to load attack JSON.");
        parser_check_attempts = 0;
        global.parser_waiting = false;
        exit;
    }

    show_debug_message("JSON loaded successfully.");

    global.timeline = scr_build_timeline_from_attack(global.current_attack_data);
    global.current_timeline_frame = 0;

    show_debug_message("Timeline built.");
    show_debug_message("Total frames: " + string(global.timeline.total_frames));
    show_debug_message("Tracks: " + string(array_length(global.timeline.tracks)));

    scr_load_sprite_folder_frames(
        global.selected_sprite_folder_path,
        global.selected_sprite_folder_name
    );

    show_debug_message("Loaded frame sprites:");
    show_debug_message(string(array_length(global.loaded_frame_sprites)));

    global.parser_waiting = false;
    parser_check_attempts = 0;

    room_goto(main_app);
}
else
{
    if (parser_check_attempts >= parser_check_max_attempts)
    {
        show_debug_message("ERROR: Parser timed out. JSON was not created:");
        show_debug_message(global.pending_json_path);

        global.parser_waiting = false;
        parser_check_attempts = 0;
    }
    else
    {
        show_debug_message("JSON not ready yet. Checking again.");
        alarm[0] = 10;
    }
}