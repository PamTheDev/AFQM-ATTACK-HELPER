function scr_get_selected_animation_key()
{
    if (!variable_global_exists("selected_animation_key"))
    {
        return undefined;
    }

    if (is_undefined(global.selected_animation_key))
    {
        return undefined;
    }

    return global.selected_animation_key;
}

function scr_get_selected_animation_key_number_value(_property_name, _default_value)
{
    var key = scr_get_selected_animation_key();

    if (is_undefined(key))
    {
        return string(_default_value);
    }

    if (!variable_struct_exists(key, _property_name))
    {
        variable_struct_set(key, _property_name, _default_value);
        return string(_default_value);
    }

    return string(variable_struct_get(key, _property_name));
}
function scr_set_selected_animation_key_number_value(_property_name, _input)
{
    var key = scr_get_selected_animation_key();

    if (is_undefined(key))
    {
        return false;
    }

    if (!scr_text_input_can_convert_to_number(_input))
    {
        return false;
    }

    var value = real(_input);

    if (_property_name == "animation_frame")
    {
        value = max(0, round(value));

        if (variable_global_exists("loaded_frame_sprites"))
        {
            var frame_count = array_length(global.loaded_frame_sprites);

            if (frame_count > 0)
            {
                value = clamp(value, 0, frame_count - 1);
            }
        }

        key.animation_frame = value;
    }
    else if (_property_name == "start")
    {
        value = max(0, round(value));
        key.start = value;
    }

    // Animation keys should stay single-frame markers.
    key.duration = 1;

    if (variable_global_exists("timeline"))
    {
        if (!is_undefined(global.timeline))
        {
            scr_sort_all_timeline_tracks(global.timeline);
            scr_recalculate_timeline_total_frames(global.timeline);
            scr_timeline_refresh_phase_indices(global.timeline);
        }
    }

    mark_attack_json_dirty();
    scr_save_current_attack_json();

    return true;
}
