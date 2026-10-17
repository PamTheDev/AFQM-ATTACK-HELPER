function scr_run_json_to_gml_converter(_json_path, _gml_path, _export_format = "Workshop")
{
    if (_export_format != "UMT" && _export_format != "Workshop") return false;
    var converter_path = working_directory + "tools/JsonToGmlConverter.exe";

    converter_path = string_replace_all(converter_path, "\\", "/");
    _json_path = string_replace_all(_json_path, "\\", "/");
    _gml_path = string_replace_all(_gml_path, "\\", "/");

    if (!file_exists(converter_path))
    {
        show_debug_message("ERROR: JSON to GML converter not found:");
        show_debug_message(converter_path);
        return false;
    }

    if (!file_exists(_json_path))
    {
        show_debug_message("ERROR: JSON file not found:");
        show_debug_message(_json_path);
        return false;
    }

    var command =
        "cmd.exe /C \"\"" +
        converter_path + "\" \"" +
        _json_path + "\" \"" +
        _gml_path + "\" " + _export_format + "\"";

    show_debug_message("Running JSON to GML converter:");
    show_debug_message(command);

    global.json_to_gml_process = ProcessExecuteAsync(command);

    return true;
}
