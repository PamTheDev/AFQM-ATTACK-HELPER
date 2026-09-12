function scr_get_text_input_value(_id)
{
    switch (_id)
    {
        
        // Hitbox function dropdown
        
        case 0:
        {
            var hb = scr_get_selected_hitbox();

            if (!is_undefined(hb))
            {
                if (variable_struct_exists(hb, "hitboxCreateFunction"))
                {
                    return scr_get_hitbox_function_index(hb.hitboxCreateFunction);
                }
            }

            return global.input0;
        }

        
        // Numeric hitbox properties
        
        case 1: return scr_get_selected_hitbox_number_value("x", 0);
        case 2: return scr_get_selected_hitbox_number_value("y", 0);
        case 3: return scr_get_selected_hitbox_number_value("xScale", 0);
        case 4: return scr_get_selected_hitbox_number_value("yScale", 0);
        case 5: return scr_get_selected_hitbox_number_value("damage", 0);
        case 6: return scr_get_selected_hitbox_number_value("bkb", 0);
        case 7: return scr_get_selected_hitbox_number_value("kbg", 0);
        case 8: return scr_get_selected_hitbox_number_value("hitlag", 0);
        case 9: return scr_get_selected_hitbox_number_value("angle", 0);
		case 10: return scr_get_selected_hitbox_key_duration();

        // Hit VFX dropdown
        case 11:
        {
            var hb = scr_get_selected_hitbox();

            if (!is_undefined(hb))
            {
                if (variable_struct_exists(hb, "vfxStyle"))
                {
                    return scr_get_hit_vfx_index(hb.vfxStyle);
                }
            }

            return 0;
        }

        // Hit SFX text
        case 12:
        {
            var hb = scr_get_selected_hitbox();

            if (is_undefined(hb))
            {
                return "";
            }

            if (!variable_struct_exists(hb, "sfx"))
            {
                hb.sfx = "";
            }

            return string(hb.sfx);
        }

        // Hitbox group
        case 13: return scr_get_selected_hitbox_number_value("group", 0);

        // Animation frame properties
        case 100: return scr_get_selected_animation_key_number_value("start", 0);
        case 101: return scr_get_selected_animation_key_number_value("animation_frame", 0);
		// Flag properties
		case 200: {
			var flag = scr_get_selected_flag();

			if (is_undefined(flag))
			{
				return "";
			}

			if (!variable_struct_exists(flag, "code"))
			{
				flag.code = "";
			}

			return flag.code;
		}
		case 201: return global.current_flag_add;

        // Phase flags/code
        case 300:
        {
            return scr_get_phase_flags_code(scr_get_selected_phase());
        }
	}
}

function scr_update_text_input(_id, _input)
{
    switch (_id)
    {
        
        // Hitbox function dropdown
        
        case 0:
        {
            var index = 0;

            if (is_real(_input))
            {
                index = _input;
            }
            else if (is_string(_input))
            {
                if (_input != "")
                {
                    index = real(_input);
                }
            }

            index = clamp(
                floor(index),
                0,
                array_length(scr_get_hitbox_function_list()) - 1
            );

            global.input0 = index;

            var hb = scr_get_selected_hitbox();

            if (!is_undefined(hb))
            {
                hb.hitboxCreateFunction = scr_get_hitbox_function_from_index(index);

                show_debug_message("Updated selected hitbox function:");
                show_debug_message(hb.hitboxCreateFunction);

                mark_attack_json_dirty();
                scr_save_current_attack_json();
            }

            break;
        }

        
        // Numeric hitbox properties
        
        case 1:
            scr_set_selected_hitbox_number_value("x", _input);
            break;

        case 2:
            scr_set_selected_hitbox_number_value("y", _input);
            break;

        case 3:
            scr_set_selected_hitbox_number_value("xScale", _input);
            break;

        case 4:
            scr_set_selected_hitbox_number_value("yScale", _input);
            break;

        case 5:
            scr_set_selected_hitbox_number_value("damage", _input);
            break;

        case 6:
            scr_set_selected_hitbox_number_value("bkb", _input);
            break;

        case 7:
            scr_set_selected_hitbox_number_value("kbg", _input);
            break;

        case 8:
            scr_set_selected_hitbox_number_value("hitlag", _input);
            break;

        case 9:
            scr_set_selected_hitbox_number_value("angle", _input);
            break;
        case 10:
			scr_set_selected_hitbox_key_duration(_input);
			break;

        case 11:
        {
            var hb = scr_get_selected_hitbox();

            if (!is_undefined(hb))
            {
                hb.vfxStyle = scr_get_hit_vfx_from_index(_input);

                mark_attack_json_dirty();
                scr_save_current_attack_json();
            }

            break;
        }

        case 12:
        {
            var hb = scr_get_selected_hitbox();

            if (!is_undefined(hb))
            {
                var new_sfx = string(_input);
                var sfx_changed = true;

                if (variable_struct_exists(hb, "sfx"))
                {
                    sfx_changed = string(hb.sfx) != new_sfx;
                }

                if (sfx_changed)
                {
                    hb.sfx = new_sfx;

                    // The undo/focus-finish path commits this edit to disk once.
                    // Avoid calling the native filesystem extension per keystroke.
                    mark_attack_json_dirty();
                }
            }

            break;
        }

        case 13:
            scr_set_selected_hitbox_number_value("group", _input);
            break;
			
		case 100:
			scr_set_selected_animation_key_number_value("start", _input);
			break;
		case 101:
			scr_set_selected_animation_key_number_value("animation_frame", _input);
			break;
			case 200:
{
    var flag = scr_get_selected_flag();

    if (!is_undefined(flag))
    {
        flag.type = "code";
        flag.code = _input;

        mark_attack_json_dirty();
        scr_save_current_attack_json();
    }

    break;
}
        case 300:
        {
            var phase = scr_get_selected_phase();

            if (!is_undefined(phase))
            {
                scr_set_phase_flags_code(phase, _input, "code");
                mark_attack_json_dirty();
                scr_save_current_attack_json();
            }

            break;
        }
    }
}

function scr_initiate_text_value(_id, _input = "", _array = "")
{
    numbers_only = false;
    text_input_type = "input";

    switch (_id)
    {
        
        // Hitbox function dropdown
        
        case 0:
        {
            text_input_type = "dropdown";
            numbers_only = false;

            global.input0_array = scr_get_hitbox_function_list();

            var hb = scr_get_selected_hitbox();

            if (!is_undefined(hb))
            {
                if (variable_struct_exists(hb, "hitboxCreateFunction"))
                {
                    global.input0 = scr_get_hitbox_function_index(hb.hitboxCreateFunction);
                }
                else
                {
                    hb.hitboxCreateFunction = "hitbox_create_melee";
                    global.input0 = 0;
                }
            }
            else
            {
                global.input0 = 0;
            }

            break;
        }

        // Hit VFX dropdown
        case 11:
        {
            text_input_type = "dropdown";
            numbers_only = false;
            break;
        }

        // Hit SFX is a sound asset name or another GML expression.
        case 12:
        {
            text_input_type = "input";
            numbers_only = false;
            break;
        }

        
        // Numeric hitbox inputs
        case 200:
        case 300:
		{
			text_input_type = "codebox";
			numbers_only = false;
			break;
		}
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
		case 10:
		case 13:
		case 100:
		case 101:
        {
            text_input_type = "input";
            numbers_only = true;
            break;
        }
    }
}

function scr_get_text_list(_id)
{
    switch (_id)
    {
        case 0:
            return scr_get_hitbox_function_list();

        case 11:
            return scr_get_hit_vfx_list();
    }

    return [];
}

function scr_get_hitbox_function_list()
{
    return [
        "hitbox_create_melee",
        "hitbox_create_magnetbox",
        "hitbox_create_grab",
        "hitbox_create_windbox",
        "hitbox_create_targetbox"
    ];
}
function scr_get_hitbox_function_index(_function_name)
{
    var list = scr_get_hitbox_function_list();

    for (var i = 0; i < array_length(list); i++)
    {
        if (list[i] == _function_name)
        {
            return i;
        }
    }

    return 0;
}
function scr_get_hitbox_function_from_index(_index)
{
    var list = scr_get_hitbox_function_list();

    _index = clamp(floor(real(_index)), 0, array_length(list) - 1);

    return list[_index];
}

function scr_get_hit_vfx_list()
{
    return [
        "normal_weak",
        "normal_medium",
        "normal_strong",
        "slash_weak",
        "slash_medium",
        "slash_strong",
        "electric_weak",
        "electric",
        "magic",
        "grab",
        "explosion",
        "splash",
        "shield",
        "shield_projectile",
        "spin",
        "lines",
        "emphasis",
        "shine",
        "custom",
        "none"
    ];
}

function scr_get_hit_vfx_index(_vfx_style)
{
    var list = scr_get_hit_vfx_list();

    for (var i = 0; i < array_length(list); i++)
    {
        if (_vfx_style == list[i] || _vfx_style == "HIT_VFX." + list[i])
        {
            return i;
        }
    }

    return 0;
}

function scr_get_hit_vfx_from_index(_index)
{
    var list = scr_get_hit_vfx_list();

    _index = clamp(floor(real(_index)), 0, array_length(list) - 1);

    return "HIT_VFX." + list[_index];
}

function scr_get_selected_hitbox()
{
    if (!variable_global_exists("selected_hitbox"))
    {
        return undefined;
    }

    if (is_undefined(global.selected_hitbox))
    {
        return undefined;
    }

    return global.selected_hitbox;
}
function scr_get_selected_hitbox_number_value(_property_name, _default_value)
{
    var hb = scr_get_selected_hitbox();

    if (is_undefined(hb))
    {
        return string(_default_value);
    }

    if (!variable_struct_exists(hb, _property_name))
    {
        variable_struct_set(hb, _property_name, _default_value);
        return string(_default_value);
    }

    var value = variable_struct_get(hb, _property_name);

    return string(value);
}

function scr_set_selected_hitbox_number_value(_property_name, _input)
{
    var hb = scr_get_selected_hitbox();

    if (is_undefined(hb))
    {
        return false;
    }

    if (!scr_text_input_can_convert_to_number(_input))
    {
        return false;
    }

    var value = real(_input);

    // Optional rounding.
    value = round(value * 100) / 100;

    variable_struct_set(hb, _property_name, value);

    mark_attack_json_dirty();
    scr_save_current_attack_json();

    return true;
}

function scr_text_input_can_convert_to_number(_text)
{
    if (is_real(_text))
    {
        return true;
    }

    if (!is_string(_text))
    {
        return false;
    }

    if (_text == "") return false;
    if (_text == "-") return false;
    if (_text == ".") return false;
    if (_text == "-.") return false;

    var last_char = string_char_at(_text, string_length(_text));

    if (last_char == ".")
    {
        return false;
    }

    return true;
}
function scr_setup_text_input(_id, _group = "default")
{
    if (!variable_global_exists("menu_focus"))
    {
        global.menu_focus = "default";
    }

    attatched_id = _id;
    input_group = _group;

    image_speed = 0;
    image_index = _id;

    scr_initiate_text_value(attatched_id);
    scr_refresh_text_input_display();

    // Only show this input if its group is currently active.
    var should_show = global.menu_focus == input_group;

    input_enabled = should_show;
    visible = should_show;
    highlighted = false;

    text_input_ready = true;
}
function scr_get_selected_hitbox_key()
{
    if (!variable_global_exists("selected_hitbox_key"))
    {
        return undefined;
    }

    if (is_undefined(global.selected_hitbox_key))
    {
        return undefined;
    }

    return global.selected_hitbox_key;
}
function scr_get_selected_hitbox_key_duration()
{
    var key = scr_get_selected_hitbox_key();

    if (is_undefined(key))
    {
        return "0";
    }

    if (!variable_struct_exists(key, "duration"))
    {
        key.duration = 1;
    }

    return string(key.duration);
}
function scr_set_selected_hitbox_key_duration(_input)
{
    var key = scr_get_selected_hitbox_key();

    if (is_undefined(key))
    {
        return false;
    }

    if (!scr_text_input_can_convert_to_number(_input))
    {
        return false;
    }

    var value = real(_input);

    value = max(1, round(value));

    key.duration = value;

    // Keep the connected hitbox's lasts value synced too.
    if (variable_struct_exists(key, "hitbox"))
    {
        if (!is_undefined(key.hitbox))
        {
            key.hitbox.lasts = value;
        }
    }

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
function scr_refresh_text_input_display()
{
    if (text_input_type == "dropdown")
    {
        current_list = scr_get_text_list(attatched_id);

        var raw_index = scr_get_text_input_value(attatched_id);
        var index = 0;

        if (is_real(raw_index))
        {
            index = raw_index;
        }
        else if (is_string(raw_index))
        {
            if (raw_index != "")
            {
                index = real(raw_index);
            }
        }

        if (array_length(current_list) > 0)
        {
            index = clamp(floor(index), 0, array_length(current_list) - 1);
            current_input = current_list[index];
        }
        else
        {
            current_input = "";
        }
    }
    else if (text_input_type == "codebox")
    {
        current_list = [];
        current_input = string(scr_get_text_input_value(attatched_id));
    }
    else
    {
        current_list = [];
        current_input = string(scr_get_text_input_value(attatched_id));
    }
}

function scr_refresh_text_input_group(_group)
{
    with (obj_text_input)
    {
        if (input_group == _group)
        {
            scr_refresh_text_input_display();
        }
    }
}
