function scr_codebox_update_input(_id)
{
    var text = keyboard_string;

    // Enter creates a new line and copies indentation.
    if (keyboard_check_pressed(vk_enter))
    {
        text += scr_codebox_make_newline_indent(text, code_indent);
        keyboard_string = text;
    }

    // Tab indents. Shift + Tab dedents the current line.
    if (keyboard_check_pressed(vk_tab))
    {
        if (keyboard_check(vk_shift))
        {
            text = scr_codebox_dedent_last_line(text, code_indent);
        }
        else
        {
            text += code_indent;
        }

        keyboard_string = text;
    }

    // Only update the model when the code actually changed. This also prevents
    // redundant per-frame JSON writes while the codebox remains focused.
    if (keyboard_string != current_input)
    {
        current_input = keyboard_string;
        scr_update_text_input(_id, current_input);
    }
}
