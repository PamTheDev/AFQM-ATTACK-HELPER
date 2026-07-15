function scr_get_gif_conversion_done_path(_gif_path, _sprite_root)
{
    _gif_path = string_replace_all(_gif_path, "\\", "/");
    _sprite_root = scr_normalize_folder_path(_sprite_root);

    var file_name = scr_get_path_folder_name(_gif_path);

    var dot_pos = 0;

    for (var i = string_length(file_name); i >= 1; i--)
    {
        if (string_char_at(file_name, i) == ".")
        {
            dot_pos = i;
            break;
        }
    }

    var sprite_name = file_name;

    if (dot_pos > 0)
    {
        sprite_name = string_copy(file_name, 1, dot_pos - 1);
    }

    return _sprite_root + sprite_name + "/conversion_done.txt";
}