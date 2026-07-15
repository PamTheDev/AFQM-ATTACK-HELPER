function scr_get_path_folder_name(_path)
{
    _path = string_replace_all(_path, "\\", "/");

    if (string_char_at(_path, string_length(_path)) == "/")
    {
        _path = string_delete(_path, string_length(_path), 1);
    }

    var last_slash = 0;

    for (var i = string_length(_path); i >= 1; i--)
    {
        if (string_char_at(_path, i) == "/")
        {
            last_slash = i;
            break;
        }
    }

    if (last_slash > 0)
    {
        return string_copy(_path, last_slash + 1, string_length(_path) - last_slash);
    }

    return _path;
}