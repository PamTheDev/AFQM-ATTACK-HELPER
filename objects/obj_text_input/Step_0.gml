if (variable_global_exists("phase_check_window_open") && global.phase_check_window_open)
{
    exit;
}

if (!text_input_ready)
{
    exit;
}

if (!input_enabled)
{
    exit;
}

if (global.text_input_instance == id)
{
    open_for++;

    if (text_input_type == "input")
    {
        var input_string = keyboard_string;

        if (numbers_only)
        {
            var filtered = "";
            var has_decimal = false;
            var has_minus = false;
            var decimal_count = 0;
            var max_decimals = 2;

            for (var i = 1; i <= string_length(input_string); i++)
            {
                var ch = string_char_at(input_string, i);

                if (string_digits(ch) != "")
                {
                    if (has_decimal)
                    {
                        if (decimal_count < max_decimals)
                        {
                            filtered += ch;
                            decimal_count += 1;
                        }
                    }
                    else
                    {
                        filtered += ch;
                    }
                }
                else if (ch == "." && !has_decimal)
                {
                    filtered += ch;
                    has_decimal = true;
                }
                else if (ch == "-" && i == 1 && !has_minus)
                {
                    filtered += ch;
                    has_minus = true;
                }
            }

            input_string = string_copy(filtered, 1, 8);
        }

        keyboard_string = input_string;

        // Do not dispatch the same value every Step. Several input setters save
        // JSON, and repeatedly opening the same file can overwhelm the native
        // filesystem extension while an input remains focused.
        if (input_string != current_input)
        {
            current_input = input_string;
            scr_update_text_input(attatched_id, input_string);
        }
    }
    else if (text_input_type == "codebox")
    {
        scr_codebox_update_input(attatched_id);
    }
}
else
{
    scr_refresh_text_input_display();
}
