if (variable_global_exists("new_attack_window_open") && global.new_attack_window_open) exit;

show_debug_message("EDIT BUTTON CLICKED");

var gml_path = global.selected_attack_gml_path;

var save_root = string_replace_all(game_save_id, "\\", "/");

if (string_char_at(save_root, string_length(save_root)) != "/")
{
    save_root += "/";
}

var json_path = save_root + "attack_json/" + global.selected_sprite_folder_name + ".json";

show_debug_message("GML path:");
show_debug_message(gml_path);

show_debug_message("JSON path:");
show_debug_message(json_path);

if (scr_run_attack_parser(gml_path, json_path))
{
    show_debug_message("Parser started. Starting Alarm 0.");
    parser_check_attempts = 0;
    alarm[0] = 10;
}
else
{
    show_debug_message("ERROR: Parser did not start.");
}
