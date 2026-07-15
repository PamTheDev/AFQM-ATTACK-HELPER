function scr_remove_file_extension(_file_name)
{
    var dot_pos = 0;

    for (var i = string_length(_file_name); i >= 1; i--)
    {
        if (string_char_at(_file_name, i) == ".")
        {
            dot_pos = i;
            break;
        }
    }

    if (dot_pos > 0)
    {
        return string_copy(_file_name, 1, dot_pos - 1);
    }

    return _file_name;
}