function scr_save_current_attack_json()
{
    if (!variable_global_exists("timeline"))
    {
        show_debug_message("Cannot save: global.timeline does not exist.");
        return false;
    }

    if (!variable_global_exists("current_attack_json_path"))
    {
        show_debug_message("Cannot save: global.current_attack_json_path does not exist.");
        return false;
    }

    if (global.current_attack_json_path == "")
    {
        show_debug_message("Cannot save: current JSON path is empty.");
        return false;
    }

    return scr_save_attack_json_from_timeline(
        global.timeline,
        global.current_attack_json_path
    );
}