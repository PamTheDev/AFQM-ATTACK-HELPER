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

function scr_flag_panel_input_should_show(_input_id, _flag_type_key)
{
    if (_input_id == 201) return true;

    if (!variable_global_exists("flag_type_submenu_open"))
    {
        global.flag_type_submenu_open = "custom_code";
    }

    return _flag_type_key == global.flag_type_submenu_open;
}

function scr_refresh_flag_type_submenu()
{
    scr_sync_selected_flag_submenu();

    with (obj_text_input)
    {
        if (input_group == "flag")
        {
            var should_show =
                global.menu_focus == "flag" &&
                scr_flag_panel_input_should_show(attatched_id, flag_type_key);

            input_enabled = should_show;
            visible = should_show;

            if (!should_show) highlighted = false;
        }
    }
}


function scr_show_only_text_input_group(_group)
{
    if (!variable_global_exists("menu_focus"))
    {
        global.menu_focus = "default";
    }

    if (_group == "flag") scr_sync_selected_flag_submenu();

    // If this group is already active, do NOT clear focus.
    if (global.menu_focus == _group)
    {
        with (obj_text_input)
        {
            var should_show = input_group == _group;

            if (should_show && _group == "flag")
            {
                should_show = scr_flag_panel_input_should_show(attatched_id, flag_type_key);
            }

            input_enabled = should_show;
            visible = should_show;

            if (!should_show)
            {
                highlighted = false;
            }
        }

        return;
    }

    // Only clear focus when actually switching groups.
    scr_clear_text_input_focus();

    global.menu_focus = _group;

    with (obj_text_input)
    {
        var should_show = input_group == _group;

        if (should_show && _group == "flag")
        {
            should_show = scr_flag_panel_input_should_show(attatched_id, flag_type_key);
        }

        input_enabled = should_show;
        visible = should_show;
        highlighted = false;

        if (should_show)
        {
            scr_refresh_text_input_display();
        }
    }
}

function scr_hide_all_text_input_groups()
{
    if (!variable_global_exists("menu_focus"))
    {
        global.menu_focus = "default";
    }

    // Already hidden; do not keep clearing focus every frame.
    if (global.menu_focus == "default")
    {
        return;
    }

    scr_clear_text_input_focus();

    global.menu_focus = "default";

    with (obj_text_input)
    {
        input_enabled = false;
        visible = false;
        highlighted = false;
    }
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
                    scr_clear_text_input_focus();
                }
            }
        }
    }
}

//global.menu_focus = _group
