function scr_clear_animation_selection()
{
    global.selected_animation_key = undefined;
    global.selected_animation_track = -1;
    global.selected_animation_key_index = -1;
}
function scr_select_animation_key(_timeline, _track_index, _key_index)
{
    if (is_undefined(_timeline))
    {
        scr_clear_animation_selection();
        return false;
    }

    if (_track_index < 0 || _track_index >= array_length(_timeline.tracks))
    {
        scr_clear_animation_selection();
        return false;
    }

    var track = _timeline.tracks[_track_index];

    if (track.type != "animation")
    {
        scr_clear_animation_selection();
        return false;
    }

    if (_key_index < 0 || _key_index >= array_length(track.keys))
    {
        scr_clear_animation_selection();
        return false;
    }

    var key = track.keys[_key_index];

    global.selected_animation_key = key;
    global.selected_animation_track = _track_index;
    global.selected_animation_key_index = _key_index;

    return true;
}

function scr_toggle_select_animation_key(_timeline, _track_index, _key_index)
{
    if (_track_index < 0 || _track_index >= array_length(_timeline.tracks))
    {
        return false;
    }

    var track = _timeline.tracks[_track_index];

    if (track.type != "animation")
    {
        return false;
    }

    if (_key_index < 0 || _key_index >= array_length(track.keys))
    {
        return false;
    }

    var key = track.keys[_key_index];

    // Click selected animation key again to deselect it.
    if (variable_global_exists("selected_animation_key"))
    {
        if (!is_undefined(global.selected_animation_key))
        {
            if (global.selected_animation_key == key)
            {
                scr_clear_animation_selection();
                scr_hide_all_text_input_groups();
                return true;
            }
        }
    }

    // Selecting animation clears hitbox selection.
    scr_clear_hitbox_selection();
    scr_select_animation_key(_timeline, _track_index, _key_index);

    scr_show_only_text_input_group("frame");

    return true;
}
function scr_clear_flag_selection()
{
    global.selected_flag_key = undefined;
    global.selected_flag_track = -1;
    global.selected_flag_key_index = -1;
}
function scr_select_flag_key(_timeline, _track_index, _key_index)
{
    if (is_undefined(_timeline))
    {
        scr_clear_flag_selection();
        return false;
    }

    if (_track_index < 0 || _track_index >= array_length(_timeline.tracks))
    {
        scr_clear_flag_selection();
        return false;
    }

    var track = _timeline.tracks[_track_index];

    if (track.type != "flag")
    {
        scr_clear_flag_selection();
        return false;
    }

    if (_key_index < 0 || _key_index >= array_length(track.keys))
    {
        scr_clear_flag_selection();
        return false;
    }

    global.selected_flag_key = track.keys[_key_index];
    global.selected_flag_track = _track_index;
    global.selected_flag_key_index = _key_index;

    return true;
}
function scr_toggle_select_flag_key(_timeline, _track_index, _key_index)
{
    if (_track_index < 0 || _track_index >= array_length(_timeline.tracks))
    {
        return false;
    }

    var track = _timeline.tracks[_track_index];

    if (track.type != "flag")
    {
        return false;
    }

    if (_key_index < 0 || _key_index >= array_length(track.keys))
    {
        return false;
    }

    var key = track.keys[_key_index];

    // Clicking the same selected flag again deselects it
    if (variable_global_exists("selected_flag_key"))
    {
        if (!is_undefined(global.selected_flag_key))
        {
            if (global.selected_flag_key == key)
            {
                scr_clear_flag_selection();
                scr_hide_all_text_input_groups();
                return true;
            }
        }
    }

    scr_clear_hitbox_selection();
    scr_clear_animation_selection();

    global.selected_flag_key = key;
    global.selected_flag_track = _track_index;
    global.selected_flag_key_index = _key_index;

    // Make sure the key has a flag struct
    if (!variable_struct_exists(key, "flag"))
    {
        key.flag = {
            type: "code",
            code: "",
            scope: "frame",
            original_line: ""
        };
    }

    if (!variable_struct_exists(key.flag, "code"))
    {
        key.flag.code = "";
    }

    scr_show_only_text_input_group("flag");

    // This forces the code panel to read the new selected flag.code
    scr_refresh_text_input_group("flag");

    return true;
}
function scr_get_selected_flag_key()
{
    if (!variable_global_exists("selected_flag_key"))
    {
        return undefined;
    }

    if (is_undefined(global.selected_flag_key))
    {
        return undefined;
    }

    return global.selected_flag_key;
}
function scr_get_selected_flag()
{
    if (!variable_global_exists("selected_flag_key"))
    {
        return undefined;
    }

    if (is_undefined(global.selected_flag_key))
    {
        return undefined;
    }

    var key = global.selected_flag_key;

    if (!variable_struct_exists(key, "flag"))
    {
        key.flag = {
            type: "code",
            code: "",
            scope: "frame",
            original_line: ""
        };
    }

    if (!variable_struct_exists(key.flag, "code"))
    {
        key.flag.code = "";
    }

    return key.flag;
}
function scr_get_active_flags(_timeline, _frame)
{
    var result = [];

    if (is_undefined(_timeline)) return result;
    if (!variable_struct_exists(_timeline, "tracks")) return result;

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        if (track.type != "flag")
        {
            continue;
        }

        for (var k = 0; k < array_length(track.keys); k++)
        {
            var key = track.keys[k];

            var key_start = key.start;
            var key_end = key.start + key.duration;

            if (_frame >= key_start && _frame < key_end)
            {
                if (variable_struct_exists(key, "flag"))
                {
                    array_push(result, key.flag);
                }
            }
        }
    }

    return result;
}
function scr_handle_flags_for_frame(_timeline, _frame)
{
    var flags = scr_get_active_flags(_timeline, _frame);

    for (var i = 0; i < array_length(flags); i++)
    {
        var flag = flags[i];

        if (!variable_struct_exists(flag, "type"))
        {
            continue;
        }

        switch (flag.type)
        {
            case "code":
            {
                // For now, do not execute code.
                // We only detect/store/edit it.
                if (variable_struct_exists(flag, "code"))
                {
                    show_debug_message("Flag code on frame " + string(_frame) + ":");
                    show_debug_message(flag.code);
                }

                break;
            }

            case "function":
            {
                // Later you can whitelist preview-safe functions here.
                if (variable_struct_exists(flag, "function_name"))
                {
                    show_debug_message("Flag function on frame " + string(_frame) + ":");
                    show_debug_message(flag.function_name);
                }

                break;
            }
        }
    }

    return flags;
}