function scr_string_repeat(_str, _count)
{
    var result = "";

    for (var i = 0; i < _count; i++)
    {
        result += _str;
    }

    return result;
}
function scr_get_last_line(_text)
{
    var last_newline = 0;

    for (var i = string_length(_text); i >= 1; i--)
    {
        var ch = string_char_at(_text, i);

        if (ch == "\n")
        {
            last_newline = i;
            break;
        }
    }

    if (last_newline == 0)
    {
        return _text;
    }

    return string_copy(
        _text,
        last_newline + 1,
        string_length(_text) - last_newline
    );
}
function scr_get_line_indent(_line)
{
    var indent = "";

    for (var i = 1; i <= string_length(_line); i++)
    {
        var ch = string_char_at(_line, i);

        if (ch == " ")
        {
            indent += " ";
        }
        else if (ch == "\t")
        {
            indent += "\t";
        }
        else
        {
            break;
        }
    }

    return indent;
}
function scr_code_line_wants_extra_indent(_line)
{
    _line = string_replace_all(_line, "\r", "");

    var len = string_length(_line);

    while (len > 0)
    {
        var ch = string_char_at(_line, len);

        if (ch == " " || ch == "\t")
        {
            len--;
        }
        else
        {
            break;
        }
    }

    if (len <= 0)
    {
        return false;
    }

    var last_char = string_char_at(_line, len);

    return
        last_char == "{" ||
        last_char == "(" ||
        last_char == "[" ||
        last_char == ":";
}
function scr_codebox_make_newline_indent(_text, _indent_string)
{
    var last_line = scr_get_last_line(_text);
    var indent = scr_get_line_indent(last_line);

    if (scr_code_line_wants_extra_indent(last_line))
    {
        indent += _indent_string;
    }

    return "\n" + indent;
}
function scr_codebox_dedent_last_line(_text, _indent_string)
{
    var last_newline = 0;

    for (var i = string_length(_text); i >= 1; i--)
    {
        if (string_char_at(_text, i) == "\n")
        {
            last_newline = i;
            break;
        }
    }

    var before = "";
    var line = _text;

    if (last_newline > 0)
    {
        before = string_copy(_text, 1, last_newline);
        line = string_copy(
            _text,
            last_newline + 1,
            string_length(_text) - last_newline
        );
    }

    var indent_len = string_length(_indent_string);

    if (string_copy(line, 1, indent_len) == _indent_string)
    {
        line = string_delete(line, 1, indent_len);
    }
    else if (string_char_at(line, 1) == "\t")
    {
        line = string_delete(line, 1, 1);
    }
    else if (string_char_at(line, 1) == " ")
    {
        var remove_count = 0;

        for (var s = 1; s <= min(4, string_length(line)); s++)
        {
            if (string_char_at(line, s) == " ")
            {
                remove_count++;
            }
            else
            {
                break;
            }
        }

        if (remove_count > 0)
        {
            line = string_delete(line, 1, remove_count);
        }
    }

    return before + line;
}