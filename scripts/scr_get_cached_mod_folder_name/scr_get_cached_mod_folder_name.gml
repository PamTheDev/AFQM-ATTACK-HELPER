function scr_get_cached_mod_folder_name()
{
    var cache_path = scr_get_last_mod_cache_path();

    if (!file_exists(cache_path))
    {
        return "";
    }

    var file = file_text_open_read(cache_path);
    var json_text = "";

    while (!file_text_eof(file))
    {
        json_text += file_text_readln(file);
    }

    file_text_close(file);

    if (json_text == "")
    {
        return "";
    }

    var cache = json_parse(json_text);

    if (!is_struct(cache))
    {
        return "";
    }

    if (!variable_struct_exists(cache, "mod_root"))
    {
        return "";
    }

    var mod_root = scr_normalize_folder_path(cache.mod_root);

    return scr_get_path_folder_name(mod_root);
}