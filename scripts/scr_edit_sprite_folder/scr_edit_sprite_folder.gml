function scr_edit_sprite_folder(_folder_name, _folder_path, _related_gml_path)
{
    global.selected_sprite_folder_name = _folder_name;
    global.selected_sprite_folder_path = _folder_path;
    global.selected_gml_path = _related_gml_path;

    show_debug_message("Editing sprite folder:");
    show_debug_message(_folder_name);
    show_debug_message(_folder_path);
    show_debug_message(_related_gml_path);

    if (_related_gml_path == "")
    {
        show_message("No related GML file found for this sprite folder.");
        return false;
    }

    var json_dir = game_save_id + "/attack_json/";

    if (!directory_exists(json_dir))
    {
        directory_create(json_dir);
    }

    var json_path = json_dir + _folder_name + ".json";

    global.pending_sprite_folder_name = _folder_name;
    global.pending_sprite_folder_path = _folder_path;
    global.pending_gml_path = _related_gml_path;
    global.pending_json_path = json_path;

    var started = scr_run_attack_parser(_related_gml_path, json_path);

    if (!started)
    {
        show_message("Could not start attack parser.");
        return false;
    }

    return true;
}