var selected_folder = get_directory("Select the mod folder");

if (selected_folder != "")
{
    global.mod_root = scr_normalize_folder_path(selected_folder);

    global.quick_load_last_mod_cache = false;
    global.use_cached_sprite_folders = false;

    show_debug_message("Selected folder:");
    show_debug_message(selected_folder);

    show_debug_message("Resolved mod root:");
    show_debug_message(global.mod_root);

    room_goto_next();
}
else
{
    show_debug_message("Selection canceled.");
}