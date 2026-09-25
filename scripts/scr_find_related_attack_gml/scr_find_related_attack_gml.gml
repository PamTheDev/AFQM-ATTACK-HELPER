function scr_find_related_attack_gml(_mod_root, _sprite_folder_name)
{
    _mod_root = scr_normalize_folder_path(_mod_root);

    var attack_name = _sprite_folder_name;

    // spr_dsmash_pulse -> dsmash_pulse
    if (scr_starts_with(attack_name, "spr_"))
    {
        attack_name = string_copy(attack_name, 5, string_length(attack_name) - 4);
    }

    show_debug_message("Looking for related GML for sprite:");
    show_debug_message(_sprite_folder_name);
    show_debug_message("Attack name:");
    show_debug_message(attack_name);

    var search_roots = [
        _mod_root,
        _mod_root + "scripts/",
        _mod_root + "Scripts/",
        _mod_root + "SCRIPTS/"
    ];

    for (var i = 0; i < array_length(search_roots); i++)
    {
        var root = scr_normalize_folder_path(search_roots[i]);

        if (!directory_exists(root))
        {
            continue;
        }

        var result = scr_find_related_attack_gml_recursive(root, attack_name, _sprite_folder_name);

        if (result != "")
        {
            show_debug_message("Related GML found:");
            show_debug_message(result);
            return result;
        }
    }

    show_debug_message("No related GML found for:");
    show_debug_message(_sprite_folder_name);

    return "";
}

/// @function scr_collect_attack_gmls(_folder)
/// @description Recursively collects GlobalScript GML files in a single pass.
function scr_collect_attack_gmls(_folder)
{
    _folder = scr_normalize_folder_path(_folder);

    var results = [];
    var found_file = file_find_first(_folder + "*.gml", 0);

    while (found_file != "")
    {
        var found_path = string_replace_all(found_file, "\\", "/");

        if (string_pos("/", found_path) == 0)
        {
            found_path = _folder + found_path;
        }

        var found_name = string_lower(scr_get_path_folder_name(found_path));

        if (scr_starts_with(found_name, "gml_globalscript_") && scr_ends_with(found_name, ".gml"))
        {
            array_push(results, found_path);
        }

        found_file = file_find_next();
    }

    file_find_close();

    // Collect subfolders before recursing because GameMaker only supports one
    // active file_find operation at a time.
    var subfolders = [];
    var found_dir = file_find_first(_folder + "*", fa_directory);

    while (found_dir != "")
    {
        var dir_path = string_replace_all(found_dir, "\\", "/");

        if (string_pos("/", dir_path) == 0)
        {
            dir_path = _folder + dir_path;
        }

        dir_path = scr_normalize_folder_path(dir_path);

        var dir_name = scr_get_path_folder_name(dir_path);

        if (dir_name != "." && dir_name != ".." && directory_exists(dir_path))
        {
            array_push(subfolders, dir_path);
        }

        found_dir = file_find_next();
    }

    file_find_close();

    for (var i = 0; i < array_length(subfolders); i++)
    {
        results = array_concat(results, scr_collect_attack_gmls(subfolders[i]));
    }

    return results;
}

/// @function scr_is_attack_gml(_gml_path)
/// @description Checks the shared attack prefix and required attack state markers.
function scr_is_attack_gml(_gml_path)
{
    if (!file_exists(_gml_path))
    {
        return false;
    }

    var file = file_text_open_read(_gml_path);
    var first_code_line = "";
    var prefix = "";
    var header = "";
    var meaningful_lines = 0;
    var lines_read = 0;

    while (!file_text_eof(file) && lines_read < 80)
    {
        var line = string_trim(file_text_readln(file));
        lines_read += 1;

        if (line == "" || scr_starts_with(line, "//"))
        {
            continue;
        }

        line = string_lower(line);

        if (first_code_line == "")
        {
            first_code_line = line;
        }

        if (meaningful_lines < 4)
        {
            prefix += line;
        }

        header += line;
        meaningful_lines += 1;
    }

    file_text_close(file);

    // Allow one leading character so a UTF-8 BOM cannot hide the function keyword.
    var function_pos = string_pos("function ", first_code_line);
    var compact_prefix = string_replace_all(prefix, " ", "");
    compact_prefix = string_replace_all(compact_prefix, chr(9), "");

    var has_common_prefix =
        function_pos > 0 &&
        function_pos <= 2 &&
        string_pos("{varrun=true;", compact_prefix) > 0;

    var has_attack_state =
        string_pos("attack_phase", header) > 0 &&
        string_pos("attack_frame", header) > 0;

    return has_common_prefix && has_attack_state;
}

/// @function scr_get_attack_key_from_gml_path(_gml_path)
/// @description Converts gml_GlobalScript_attack_name.gml to attack_name.
function scr_get_attack_key_from_gml_path(_gml_path)
{
    var file_name = scr_get_path_folder_name(string_replace_all(_gml_path, "\\", "/"));
    var lower_name = string_lower(file_name);
    var prefix = "gml_globalscript_";
    var suffix = ".gml";

    if (!scr_starts_with(lower_name, prefix) || !scr_ends_with(lower_name, suffix))
    {
        return "";
    }

    var key_length = string_length(file_name) - string_length(prefix) - string_length(suffix);

    if (key_length <= 0)
    {
        return "";
    }

    return string_copy(file_name, string_length(prefix) + 1, key_length);
}
