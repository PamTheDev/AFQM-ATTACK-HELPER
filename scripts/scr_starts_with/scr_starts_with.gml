function scr_starts_with(_str, _prefix)
{
    return string_copy(_str, 1, string_length(_prefix)) == _prefix;
}