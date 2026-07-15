function scr_load_json_file(_json_path)
{
    if (!file_exists(_json_path))
    {
        show_debug_message("JSON file does not exist:");
        show_debug_message(_json_path);
        return undefined;
    }

    var file = file_text_open_read(_json_path);
    var json_text = "";

    while (!file_text_eof(file))
    {
        json_text += file_text_read_string(file);
        file_text_readln(file);
    }

    file_text_close(file);

    show_debug_message("JSON text loaded. Length:");
    show_debug_message(string(string_length(json_text)));

    return json_parse(json_text);
}