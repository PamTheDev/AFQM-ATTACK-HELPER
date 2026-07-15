function scr_ends_with(_str, _suffix)
{
    var suffix_len = string_length(_suffix);
    var str_len = string_length(_str);

    if (suffix_len > str_len)
    {
        return false;
    }

    return string_copy(_str, str_len - suffix_len + 1, suffix_len) == _suffix;
}