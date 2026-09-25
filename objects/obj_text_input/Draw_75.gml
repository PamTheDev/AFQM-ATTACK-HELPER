if (!text_input_ready)
{
    exit;
}

if (!input_enabled)
{
    highlighted = false;
    exit;
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var input_w = 32 * image_xscale;
var input_h = 32 * image_yscale;

if (text_input_type == "dropdown")
	input_w += 20

// Instances of this object share a draw depth. If another input overlaps an
// open dropdown, do not draw that covered input over the option list. This is
// independent of GameMaker's instance draw order and works on the opening frame.
if (
    global.text_input_instance != noone &&
    global.text_input_instance != id &&
    instance_exists(global.text_input_instance)
)
{
    var open_dropdown_input = global.text_input_instance;

    if (open_dropdown_input.text_input_type == "dropdown")
    {
        var open_dropdown_count = array_length(open_dropdown_input.current_list);

        if (open_dropdown_count > 0)
        {
            var open_input_w = 32 * open_dropdown_input.image_xscale;
            var open_input_h = 32 * open_dropdown_input.image_yscale;
            var open_option_h = open_input_h;
            var open_dropdown_y = open_dropdown_input.y + open_input_h;
            var open_dropdown_full_h = open_option_h * open_dropdown_count;
            var open_gui_h = display_get_gui_height();

            if (
                open_dropdown_y + open_dropdown_full_h > open_gui_h &&
                open_dropdown_input.y > open_gui_h - open_dropdown_y
            )
            {
                open_option_h = max(
                    16,
                    min(
                        open_input_h,
                        floor(open_dropdown_input.y / open_dropdown_count)
                    )
                );

                open_dropdown_y = open_dropdown_input.y - open_option_h * open_dropdown_count;
            }

            var covered_by_dropdown =
                x < open_dropdown_input.x + open_input_w &&
                x + input_w > open_dropdown_input.x &&
                y < open_dropdown_y + open_option_h * open_dropdown_count &&
                y + input_h > open_dropdown_y;

            if (covered_by_dropdown)
            {
                highlighted = false;
                exit;
            }
        }
    }
}

highlighted =
    mx >= x &&
    mx <= x + input_w &&
    my >= y &&
    my <= y + input_h;

var clicked = mouse_check_button_pressed(mb_left);

// An open dropdown is modal to the other text inputs. Without this guard, an
// input underneath an option can take focus before the option handles the click.
if (
    global.text_input_instance != noone &&
    global.text_input_instance != id &&
    instance_exists(global.text_input_instance)
)
{
    var focused_input = global.text_input_instance;

    if (focused_input.text_input_type == "dropdown")
    {
        highlighted = false;
        clicked = false;
    }
}

// Keep long dropdowns inside the GUI. Short dropdowns retain their existing
// downward-opening layout and full-height rows.
var dropdown_option_h = input_h;
var dropdown_y = y + input_h;

if (text_input_type == "dropdown" && array_length(current_list) > 0)
{
    var dropdown_count = array_length(current_list);
    var dropdown_full_h = dropdown_option_h * dropdown_count;
    var gui_h = display_get_gui_height();

    if (dropdown_y + dropdown_full_h > gui_h && y > gui_h - dropdown_y)
    {
        dropdown_option_h = max(16, min(input_h, floor(y / dropdown_count)));
        dropdown_y = y - dropdown_option_h * dropdown_count;
    }
}



// Dropdown option click


if (
    clicked &&
    global.text_input_instance == id &&
    text_input_type == "dropdown"
)
{
    var bx = x;
    var bw = 32 * image_xscale;

    for (var i = 0; i < array_length(current_list); i++)
    {
        var option_y = dropdown_y + dropdown_option_h * i;

        var mouse_hover_option =
            mx >= bx &&
            mx <= bx + bw &&
            my >= option_y &&
            my <= option_y + dropdown_option_h;

        if (mouse_hover_option)
        {
            scr_update_text_input(attatched_id, i);
            scr_refresh_text_input_display();

            scr_text_input_finish_property_undo();

            global.text_input_focused = false;
            global.text_input_id = undefined;
            global.text_input_instance = noone;
            keyboard_string = "";

            clicked = false;
            break;
        }
    }
}



// Clicking the dropdown's top field again closes it, matching an outside click.


if (
    clicked &&
    highlighted &&
    global.text_input_instance == id &&
    text_input_type == "dropdown"
)
{
    scr_text_input_finish_property_undo();

    global.text_input_focused = false;
    global.text_input_id = undefined;
    global.text_input_instance = noone;
    keyboard_string = "";

    // Do not let the focus block below immediately reopen the dropdown.
    clicked = false;
}



// Click input to focus/select


if (clicked && highlighted)
{
    if (variable_global_exists("text_input_instance"))
    {
        if (global.text_input_instance != noone)
        {
            if (instance_exists(global.text_input_instance))
            {
                if (global.text_input_instance != id)
                {
                    with (global.text_input_instance)
                    {
                        scr_text_input_finish_property_undo();
                    }
                }
            }
        }
    }

    open_for = 0;

    scr_refresh_text_input_display();

    keyboard_string = current_input;

    global.text_input_focused = true;
    global.text_input_id = attatched_id;
    global.text_input_instance = id;

    scr_text_input_begin_property_undo(attatched_id);
}



// Click outside this focused input to deselect


if (
    clicked &&
    global.text_input_instance == id &&
    !highlighted
)
{
    var clicked_dropdown_area = false;

    if (text_input_type == "dropdown")
    {
        var dbx = x;
        var dbw = (32 * image_xscale) + 20;



        var dropdown_top = dropdown_y;
        var dropdown_bottom = dropdown_y + dropdown_option_h * array_length(current_list);

        clicked_dropdown_area =
            mx >= dbx &&
            mx <= dbx + dbw &&
            my >= dropdown_top &&
            my <= dropdown_bottom;
    }

    if (!clicked_dropdown_area)
    {
        scr_text_input_finish_property_undo();

        global.text_input_focused = false;
        global.text_input_id = undefined;
        global.text_input_instance = noone;
        keyboard_string = "";
    }
}



// Draw input box


draw_set_colour(c_dkgray);

if global.text_input_instance == id
			draw_set_colour(merge_colour(c_gray, c_dkgray, 0.8))
			
if (highlighted)
{
    draw_set_colour(c_gray);
}

draw_rectangle(
    x,
    y,
    x + input_w,
    y + input_h,
    false
);

// Draw dropdown


if (text_input_type == "dropdown" && global.text_input_instance == id)
{
    var bx2 = x;
    var bw2 = 32 * image_xscale + 20;

    for (var d = 0; d < array_length(current_list); d++)
    {
        var option_y2 = dropdown_y + dropdown_option_h * d;

        var mouse_hover_button =
            mx >= bx2 &&
            mx <= bx2 + bw2 &&
            my >= option_y2 &&
            my <= option_y2 + dropdown_option_h;

        draw_set_colour(c_dkgray);
		
        if (mouse_hover_button)
        {
            draw_set_colour(c_gray);
        }
		
        draw_rectangle(
            bx2,
            option_y2,
            bx2 + bw2,
            option_y2 + dropdown_option_h,
            false
        );

        draw_set_colour(c_white);
        draw_text(bx2 + 4, option_y2 + 6, current_list[d]);
    }
}


if (text_input_type == "dropdown")
{
	draw_set_colour(c_white);
	if global.text_input_instance == id
		{
			draw_triangle(
			x + input_w - 20,
			y + input_h / 2,
			x + input_w - 5,
			y + input_h / 2,
			x + input_w - 12,
			y + input_h / 3,
			false
			);
		}
	else
		{
			draw_triangle(
			x+ input_w - 20,
			y + input_h / 2,
			x+ input_w - 5,
			y + input_h / 2,
			x+ input_w - 12,
			y + input_h / 1.5,
			false
			);
		}
}

// Draw codebox text
if (text_input_type == "codebox")
{
    draw_set_colour(c_white);

    var draw_x = x + code_padding;
    var draw_y = y + code_padding - code_scroll_y;

    var line = "";
    var line_index = 0;

    // These store where the cursor should draw.
    var cursor_x = draw_x;
    var cursor_y = draw_y;

    for (var i = 1; i <= string_length(current_input); i++)
    {
        var ch = string_char_at(current_input, i);

        if (ch == "\n")
        {
            draw_text(
                draw_x,
                draw_y + line_index * code_line_height,
                line
            );

            // If the text ends with a newline, the cursor should move
            // to the start of the next empty line.
            line = "";
            line_index++;

            cursor_x = draw_x;
            cursor_y = draw_y + line_index * code_line_height;
        }
        else
        {
            line += ch;

            cursor_x = draw_x + string_width(line);
            cursor_y = draw_y + line_index * code_line_height;
        }
    }

    // Draw the final line.
    draw_text(
        draw_x,
        draw_y + line_index * code_line_height,
        line
    );

    // Make sure the cursor is at the end of the final line.
    cursor_x = draw_x + string_width(line);
    cursor_y = draw_y + line_index * code_line_height;

    // Draw cursor.
    if (global.text_input_instance == id)
    {
        draw_set_colour(c_white);

        draw_line(
            cursor_x + 2,
            cursor_y,
            cursor_x + 2,
            cursor_y + code_line_height
        );
    }
}
else
{
    draw_set_colour(c_white);
    draw_text(x + 4, y + 6, current_input);
}
