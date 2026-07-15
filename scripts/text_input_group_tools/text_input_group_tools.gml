function scr_clear_text_input_focus()
{
    if (variable_global_exists("text_input_instance"))
    {
        if (global.text_input_instance != noone)
        {
            if (instance_exists(global.text_input_instance))
            {
                with (global.text_input_instance)
                {
                    scr_text_input_finish_property_undo();
                }
            }
        }
    }

    global.text_input_focused = false;
    global.text_input_id = undefined;
    global.text_input_instance = noone;
    keyboard_string = "";
}


function scr_set_text_input_group_enabled(_group, _enabled)
{
    with (obj_text_input)
    {
        if (input_group == _group)
        {
            input_enabled = _enabled;
            visible = _enabled;

            if (!_enabled)
            {
                highlighted = false;

                if (global.text_input_instance == id)
                {
                    scr_text_input_finish_property_undo();

                    global.text_input_focused = false;
                    global.text_input_id = undefined;
                    global.text_input_instance = noone;
                    keyboard_string = "";
                }
            }
        }
    }
}


function scr_hide_all_text_input_groups()
{
	global.menu_focus = "default"
    with (obj_text_input)
    {
        input_enabled = false;
        visible = false;
        highlighted = false;

        if (global.text_input_instance == id)
        {
            scr_text_input_finish_property_undo();

            global.text_input_focused = false;
            global.text_input_id = undefined;
            global.text_input_instance = noone;
            keyboard_string = "";
        }
    }
}

//global.menu_focus = _group
function scr_show_only_text_input_group(_group)
{
    scr_clear_text_input_focus();
global.menu_focus = _group
    with (obj_text_input)
    {
        var should_show = input_group == _group;

        input_enabled = should_show;
        visible = should_show;
        highlighted = false;

        if (should_show)
        {
            scr_refresh_text_input_display();
        }
    }
}