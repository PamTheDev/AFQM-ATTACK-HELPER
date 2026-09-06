function scr_run_gif_converter(_gif_path, _sprite_root)
{
    var converter_path = working_directory + "tools/GIFtoFolders.exe";

    converter_path = string_replace_all(converter_path, "\\", "/");
    _gif_path = string_replace_all(_gif_path, "\\", "/");
    _sprite_root = scr_normalize_folder_path(_sprite_root);

    var save_root = scr_normalize_folder_path(game_save_id);
    var log_dir = save_root + "gif_converter_logs/";

    if (!directory_exists(log_dir))
    {
        directory_create(log_dir);
    }

    var gif_file_name = scr_get_path_folder_name(_gif_path);
    var log_path = log_dir + gif_file_name + ".log";

    if (file_exists(log_path))
    {
        file_delete(log_path);
    }

    show_debug_message("GIF converter path:");
    show_debug_message(converter_path);

    show_debug_message("GIF path:");
    show_debug_message(_gif_path);

    show_debug_message("Sprite root:");
    show_debug_message(_sprite_root);

    show_debug_message("GIF converter log:");
    show_debug_message(log_path);

    if (!file_exists(converter_path))
    {
        show_debug_message("ERROR: GIF converter exe not found.");
        return false;
    }

    if (!file_exists(_gif_path))
    {
        show_debug_message("ERROR: GIF file not found.");
        return false;
    }

    if (!directory_exists(_sprite_root))
    {
        show_debug_message("ERROR: Sprite root does not exist.");
        return false;
    }
	
	
	convert_gif_gml(_gif_path, _sprite_root);
	
	/*
    var command =
        "cmd.exe /C \"\"" +
        converter_path + "\" \"" +
        _gif_path + "\" \"" +
        _sprite_root + "\" > \"" +
        log_path + "\" 2>&1\"";

    show_debug_message("Running GIF converter command:");
    show_debug_message(command);

    global.gif_converter_process = ProcessExecuteAsync(command);
	
    show_debug_message("xProcess returned:");
    show_debug_message(string(global.gif_converter_process));
	*/
	
	
    return true;
}