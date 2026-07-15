function scr_text_input_get_property_name(_id)
{
    switch (_id)
    {
        case 0: return "hitboxCreateFunction";
        case 1: return "x";
        case 2: return "y";
        case 3: return "xScale";
        case 4: return "yScale";
        case 5: return "damage";
        case 6: return "bkb";
        case 7: return "kbg";
        case 8: return "hitlag";
        case 9: return "angle";
        case 10: return "duration";
    }

    return "";
}


function scr_text_input_get_undo_target(_id)
{
    if (_id == 10)
    {
        if (variable_global_exists("selected_hitbox_key"))
        {
            if (!is_undefined(global.selected_hitbox_key))
            {
                return global.selected_hitbox_key;
            }
        }

        return undefined;
    }

    return scr_get_selected_hitbox();
}


function scr_text_input_read_target_value(_id, _target)
{
    if (is_undefined(_target))
    {
        return undefined;
    }

    if (_id == 0)
    {
        if (variable_struct_exists(_target, "hitboxCreateFunction"))
        {
            return _target.hitboxCreateFunction;
        }

        return "hitbox_create_melee";
    }

    if (_id == 10)
    {
        if (variable_struct_exists(_target, "duration"))
        {
            return _target.duration;
        }

        return 1;
    }

    var prop = scr_text_input_get_property_name(_id);

    if (prop == "")
    {
        return undefined;
    }

    if (variable_struct_exists(_target, prop))
    {
        return variable_struct_get(_target, prop);
    }

    return 0;
}


function scr_text_input_write_target_value(_id, _target, _value)
{
    if (is_undefined(_target))
    {
        return false;
    }

    if (_id == 0)
    {
        if (is_string(_value))
        {
            _target.hitboxCreateFunction = _value;
        }
        else
        {
            _target.hitboxCreateFunction = scr_get_hitbox_function_from_index(_value);
        }

        return true;
    }

    if (_id == 10)
    {
        var duration = max(1, round(real(_value)));

        _target.duration = duration;

        if (variable_struct_exists(_target, "hitbox"))
        {
            if (!is_undefined(_target.hitbox))
            {
                _target.hitbox.lasts = duration;
            }
        }

        return true;
    }

    var prop = scr_text_input_get_property_name(_id);

    if (prop == "")
    {
        return false;
    }

    variable_struct_set(_target, prop, real(_value));

    return true;
}


function scr_text_input_begin_property_undo(_id)
{
    text_input_undo_active = false;
    text_input_undo_id = -1;
    text_input_undo_target = undefined;
    text_input_undo_before = undefined;
    text_input_undo_property = "";

    var target = scr_text_input_get_undo_target(_id);

    if (is_undefined(target))
    {
        return false;
    }

    text_input_undo_active = true;
    text_input_undo_id = _id;
    text_input_undo_target = target;
    text_input_undo_before = scr_text_input_read_target_value(_id, target);
    text_input_undo_property = scr_text_input_get_property_name(_id);

    show_debug_message("Started text input undo for:");
    show_debug_message(text_input_undo_property);

    return true;
}


function scr_text_input_finish_property_undo()
{
    if (!text_input_undo_active)
    {
        return false;
    }

    if (is_undefined(text_input_undo_target))
    {
        text_input_undo_active = false;
        return false;
    }

    var after_value = scr_text_input_read_target_value(
        text_input_undo_id,
        text_input_undo_target
    );

    if (text_input_undo_before != after_value)
    {
        if (!variable_global_exists("undo_history"))
        {
            global.undo_history = [];
        }

        array_push(global.undo_history, {
            type: "hitbox_property_edit",
            input_id: text_input_undo_id,
            property: text_input_undo_property,
            target: text_input_undo_target,
            before: text_input_undo_before,
            after: after_value
        });

        show_debug_message("Added hitbox property undo action:");
        show_debug_message(text_input_undo_property);
        show_debug_message("Undo count: " + string(array_length(global.undo_history)));

        mark_attack_json_dirty();
        scr_save_current_attack_json();
    }

    text_input_undo_active = false;
    text_input_undo_id = -1;
    text_input_undo_target = undefined;
    text_input_undo_before = undefined;
    text_input_undo_property = "";

    return true;
}