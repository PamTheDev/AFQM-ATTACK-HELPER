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

highlighted =
    mx >= x &&
    mx <= x + input_w &&
    my >= y &&
    my <= y + input_h;

var clicked = mouse_check_button_pressed(mb_left);



// Dropdown option click


if (
    clicked &&
    global.text_input_instance == id &&
    text_input_type == "dropdown"
)
{
    var bx = x;
    var bw = 32 * image_xscale;
    var bh = 32 * image_yscale;

    for (var i = 0; i < array_length(current_list); i++)
    {
        var option_y = y + bh * (i + 1);

        var mouse_hover_option =
            mx >= bx &&
            mx <= bx + bw &&
            my >= option_y &&
            my <= option_y + bh;

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
        var dbw = 32 * image_xscale;
        var dbh = 32 * image_yscale;

        var dropdown_top = y + dbh;
        var dropdown_bottom = y + dbh * (array_length(current_list) + 1);

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
    var bw2 = 32 * image_xscale;
    var bh2 = 32 * image_yscale;

    for (var d = 0; d < array_length(current_list); d++)
    {
        var option_y2 = y + bh2 * (d + 1);

        var mouse_hover_button =
            mx >= bx2 &&
            mx <= bx2 + bw2 &&
            my >= option_y2 &&
            my <= option_y2 + bh2;

        draw_set_colour(c_dkgray);
		
        if (mouse_hover_button)
        {
            draw_set_colour(c_gray);
        }
		
        draw_rectangle(
            bx2,
            option_y2,
            bx2 + bw2,
            option_y2 + bh2,
            false
        );

        draw_set_colour(c_white);
        draw_text(bx2 + 4, option_y2 + 6, current_list[d]);
    }
}



// Draw current text


draw_set_colour(c_white);
draw_text(x + 4, y + 6, current_input);