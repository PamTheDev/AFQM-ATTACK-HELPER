function scr_run_attack_parser(_gml_path, _json_path)
{
    var parser_path = working_directory + "tools/AttackParser.exe";

    parser_path = string_replace_all(parser_path, "\\", "/");
    _gml_path = string_replace_all(_gml_path, "\\", "/");
    _json_path = string_replace_all(_json_path, "\\", "/");

    if (!file_exists(parser_path))
    {
        show_debug_message("ERROR: Parser not found:");
        show_debug_message(parser_path);
        return false;
    }

    if (!file_exists(_gml_path))
    {
        show_debug_message("ERROR: GML file not found:");
        show_debug_message(_gml_path);
        return false;
    }

    var json_dir = filename_path(_json_path);

    if (!directory_exists(json_dir))
    {
        directory_create(json_dir);
    }

    if (!directory_exists(json_dir))
    {
        show_debug_message("ERROR: Could not create JSON directory:");
        show_debug_message(json_dir);
        return false;
    }

    if (file_exists(_json_path))
    {
        file_delete(_json_path);
    }

    var command =
        "cmd.exe /C \"\"" +
        parser_path + "\" \"" +
        _gml_path + "\" \"" +
        _json_path + "\"\"";

    show_debug_message("Running parser command:");
    show_debug_message(command);

    global.parser_process = ProcessExecuteAsync(command);
    global.pending_json_path = _json_path;
    global.parser_waiting = true;

    show_debug_message("xProcess returned process handle/id:");
    show_debug_message(string(global.parser_process));

    return true;
}