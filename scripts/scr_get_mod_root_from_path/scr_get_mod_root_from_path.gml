function scr_get_mod_root_from_path(_path)
{
    _path = string_replace_all(_path, "\\", "/");

    if (_path != "")
    {
        if (string_char_at(_path, string_length(_path)) != "/")
        {
            _path += "/";
        }
    }

    var lower_path = string_lower(_path);

    // If the selected path is inside a scripts folder, cut the path above scripts.
    var scripts_marker = "/scripts/";
    var scripts_pos = string_pos(scripts_marker, lower_path);

    if (scripts_pos > 0)
    {
        // Keep everything before "/scripts/"
        return string_copy(_path, 1, scripts_pos);
    }

    // If no scripts folder was found, use the selected folder as-is.
    return _path;
}