function scr_get_flag_track_index(_timeline)
{
    if (is_undefined(_timeline)) return -1;
    if (!variable_struct_exists(_timeline, "tracks")) return -1;

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        if (_timeline.tracks[t].type == "flag")
        {
            return t;
        }
    }

    return -1;
}
function scr_get_or_create_flag_track(_timeline)
{
    var track_index = scr_get_flag_track_index(_timeline);

    if (track_index != -1)
    {
        return track_index;
    }

    var new_track = {
        name: "Flags",
        type: "flag",
        keys: []
    };

    array_push(_timeline.tracks, new_track);

    return array_length(_timeline.tracks) - 1;
}
function scr_make_code_flag(_code, _scope = "frame", _original_line = "")
{
    return {
        type: "code",
        code: _code,
        scope: _scope,
        original_line: _original_line
    };
}

// Flag panel definitions live in one list so adding another flag type only
// requires a definition here. Function flag code and panel inputs are both
// generated from this data.
function scr_get_flag_type_definitions()
{
    return [
        {
            key: "custom_code",
            label: "Custom Code",
            function_name: "",
            inputs: [
                { id: 200, label: "Code:", property: "code", default_value: "", input_type: "codebox", numbers_only: false }
            ]
        },
        {
            key: "game_sound_play",
            label: "game_sound_play",
            function_name: "game_sound_play",
            inputs: [
                { id: 202, label: "Sound:", property: "sound", default_value: "0", input_type: "input", numbers_only: false }
            ]
        },
        {
            key: "vfx",
            label: "vfx",
            function_name: "vfx_create",
            inputs: [
                { id: 210, label: "Sprite:", property: "sprite", default_value: "0", input_type: "input", numbers_only: false },
                { id: 211, label: "Image Speed:", property: "image_speed", default_value: "1", input_type: "input", numbers_only: false },
                { id: 212, label: "Start Frame:", property: "start_frame", default_value: "0", input_type: "input", numbers_only: false },
                { id: 213, label: "Lifetime:", property: "lifetime", default_value: "1", input_type: "input", numbers_only: false },
                { id: 214, label: "X:", property: "x", default_value: "x", input_type: "input", numbers_only: false },
                { id: 215, label: "Y:", property: "y", default_value: "y", input_type: "input", numbers_only: false },
                { id: 216, label: "Scale:", property: "scale", default_value: "1", input_type: "input", numbers_only: false },
                { id: 217, label: "Angle:", property: "angle", default_value: "0", input_type: "input", numbers_only: false },
                { id: 218, label: "Layer (optional):", property: "layer", default_value: "", input_type: "input", numbers_only: false, optional: true }
            ]
        },
        {
            key: "hitbox_reset",
            label: "hitbox_reset",
            function_name: "hitbox_group_reset",
            inputs: [
                { id: 219, label: "Group:", property: "group", default_value: "0", input_type: "input", numbers_only: false }
            ]
        },
        {
            key: "speed_set",
            label: "speed_set",
            function_name: "speed_set",
            inputs: [
                { id: 220, label: "X Speed:", property: "x_speed", default_value: "0", input_type: "input", numbers_only: false },
                { id: 221, label: "Y Speed:", property: "y_speed", default_value: "0", input_type: "input", numbers_only: false },
                { id: 222, label: "Relative X (optional):", property: "relative_x", default_value: "false", input_type: "input", numbers_only: false, optional: true },
                { id: 223, label: "Relative Y (optional):", property: "relative_y", default_value: "false", input_type: "input", numbers_only: false, optional: true }
            ]
        },
        {
            key: "calculate_smash_damage",
            label: "calculate_smash_damage",
            function_name: "calculate_smash_damage",
            inputs: [
                { id: 231, label: "Base Damage:", property: "damage", default_value: "0", input_type: "input", numbers_only: false },
                { id: 232, label: "Charge (optional):", property: "charge", default_value: "", placeholder: "charge", input_type: "input", numbers_only: false, optional: true },
                { id: 233, label: "Max Charge (optional):", property: "max_charge", default_value: "", placeholder: "smash_attack_charge_max", input_type: "input", numbers_only: false, optional: true },
                { id: 234, label: "Multiplier (optional):", property: "multiplier", default_value: "", placeholder: "smash_attack_multiplier", input_type: "input", numbers_only: false, optional: true }
            ]
        }
    ];
}

function scr_get_flag_type_names()
{
    var definitions = scr_get_flag_type_definitions();
    var names = [];

    for (var i = 0; i < array_length(definitions); i++)
    {
        array_push(names, definitions[i].label);
    }

    return names;
}

function scr_get_flag_type_index_from_key(_key)
{
    var definitions = scr_get_flag_type_definitions();

    for (var i = 0; i < array_length(definitions); i++)
    {
        if (definitions[i].key == _key) return i;
    }

    return 0;
}

function scr_get_flag_type_definition_from_key(_key)
{
    var definitions = scr_get_flag_type_definitions();
    var index = scr_get_flag_type_index_from_key(_key);
    return definitions[index];
}

function scr_get_flag_input_definition(_input_id)
{
    var definitions = scr_get_flag_type_definitions();

    for (var i = 0; i < array_length(definitions); i++)
    {
        var inputs = definitions[i].inputs;

        for (var f = 0; f < array_length(inputs); f++)
        {
            if (inputs[f].id == _input_id)
            {
                return {
                    type_key: definitions[i].key,
                    type_label: definitions[i].label,
                    function_name: definitions[i].function_name,
                    field: inputs[f]
                };
            }
        }
    }

    return undefined;
}

function scr_split_flag_function_arguments(_arguments)
{
    var result = [];
    var argument_buffer = "";
    var parenthesis_depth = 0;
    var quote = "";
    var previous = "";

    for (var i = 1; i <= string_length(_arguments); i++)
    {
        var character = string_char_at(_arguments, i);

        if (quote != "")
        {
            argument_buffer += character;

            if (character == quote && previous != "\\") quote = "";
        }
        else if (character == "\"" || character == "'")
        {
            quote = character;
            argument_buffer += character;
        }
        else if (character == "(")
        {
            parenthesis_depth++;
            argument_buffer += character;
        }
        else if (character == ")")
        {
            parenthesis_depth--;
            argument_buffer += character;
        }
        else if (character == "," && parenthesis_depth == 0)
        {
            array_push(result, string_trim(argument_buffer));
            argument_buffer = "";
        }
        else
        {
            argument_buffer += character;
        }

        previous = character;
    }

    if (argument_buffer != "" || string_length(_arguments) > 0)
    {
        array_push(result, string_trim(argument_buffer));
    }

    return result;
}

function scr_try_infer_flag_submenu(_flag)
{
    if (is_undefined(_flag)) return "custom_code";

    if (variable_struct_exists(_flag, "ui_type"))
    {
        var saved_key = string(_flag.ui_type);
        var saved_definitions = scr_get_flag_type_definitions();

        for (var saved_index = 0; saved_index < array_length(saved_definitions); saved_index++)
        {
            if (saved_definitions[saved_index].key == saved_key) return saved_key;
        }
    }

    var code = "";
    if (variable_struct_exists(_flag, "code")) code = string_trim(string(_flag.code));

    if (string_char_at(code, string_length(code)) == ";")
    {
        code = string_trim(string_delete(code, string_length(code), 1));
    }

    var definitions = scr_get_flag_type_definitions();

    for (var i = 1; i < array_length(definitions); i++)
    {
        var definition = definitions[i];
        var prefix = definition.function_name + "(";

        if (
            string_copy(code, 1, string_length(prefix)) == prefix &&
            string_char_at(code, string_length(code)) == ")"
        )
        {
            var argument_text = string_copy(
                code,
                string_length(prefix) + 1,
                string_length(code) - string_length(prefix) - 1
            );
            var arguments = scr_split_flag_function_arguments(argument_text);

            var required_argument_count = 0;

            for (var required_index = 0; required_index < array_length(definition.inputs); required_index++)
            {
                var required_field = definition.inputs[required_index];
                var field_is_optional =
                    variable_struct_exists(required_field, "optional") &&
                    required_field.optional;

                if (!field_is_optional) required_argument_count++;
            }

            if (
                array_length(arguments) >= required_argument_count &&
                array_length(arguments) <= array_length(definition.inputs)
            )
            {
                for (var a = 0; a < array_length(definition.inputs); a++)
                {
                    var argument_value = definition.inputs[a].default_value;
                    if (a < array_length(arguments)) argument_value = arguments[a];

                    variable_struct_set(_flag, definition.inputs[a].property, argument_value);
                }

                _flag.ui_type = definition.key;
                return definition.key;
            }
        }
    }

    _flag.ui_type = "custom_code";
    return "custom_code";
}

function scr_sync_selected_flag_submenu()
{
    if (!variable_global_exists("flag_type_submenu_open"))
    {
        global.flag_type_submenu_open = "custom_code";
    }

    var flag = scr_get_selected_flag();

    if (!is_undefined(flag))
    {
        global.flag_type_submenu_open = scr_try_infer_flag_submenu(flag);
    }

    return global.flag_type_submenu_open;
}

function scr_rebuild_flag_code(_flag)
{
    if (is_undefined(_flag)) return false;

    var type_key = scr_try_infer_flag_submenu(_flag);
    var definition = scr_get_flag_type_definition_from_key(type_key);

    _flag.type = "code";
    _flag.scope = "frame";

    if (type_key != "custom_code")
    {
        var code = definition.function_name + "(";
        var generated_argument_count = array_length(definition.inputs);

        // Optional blank inputs are omitted from the end of the function call.
        while (generated_argument_count > 0)
        {
            var trailing_field = definition.inputs[generated_argument_count - 1];
            var trailing_is_optional =
                variable_struct_exists(trailing_field, "optional") &&
                trailing_field.optional;

            if (!trailing_is_optional) break;

            if (!variable_struct_exists(_flag, trailing_field.property))
            {
                variable_struct_set(_flag, trailing_field.property, trailing_field.default_value);
            }

            if (string(variable_struct_get(_flag, trailing_field.property)) != "") break;
            generated_argument_count--;
        }

        for (var i = 0; i < generated_argument_count; i++)
        {
            var field = definition.inputs[i];

            if (!variable_struct_exists(_flag, field.property))
            {
                variable_struct_set(_flag, field.property, field.default_value);
            }

            if (i > 0) code += ", ";

            var field_value = string(variable_struct_get(_flag, field.property));

            // Optional arguments before another supplied argument still need an
            // explicit engine-default expression to keep the call valid.
            if (
                field_value == "" &&
                variable_struct_exists(field, "placeholder")
            )
            {
                field_value = field.placeholder;
            }

            code += field_value;
        }

        code += ");";
        _flag.code = code;
    }
    else if (!variable_struct_exists(_flag, "code"))
    {
        _flag.code = "";
    }

    if (type_key == "custom_code")
    {
        _flag.custom_code = _flag.code;
    }

    _flag.original_line = _flag.code;
    return true;
}

function scr_apply_flag_type(_flag, _type_key)
{
    if (is_undefined(_flag)) return false;

    var old_type_key = scr_try_infer_flag_submenu(_flag);

    if (old_type_key == "custom_code" && variable_struct_exists(_flag, "code"))
    {
        _flag.custom_code = _flag.code;
    }

    var definition = scr_get_flag_type_definition_from_key(_type_key);
    _flag.ui_type = definition.key;

    if (
        definition.key == "custom_code" &&
        variable_struct_exists(_flag, "custom_code")
    )
    {
        _flag.code = _flag.custom_code;
    }

    for (var i = 0; i < array_length(definition.inputs); i++)
    {
        var field = definition.inputs[i];

        if (!variable_struct_exists(_flag, field.property))
        {
            variable_struct_set(_flag, field.property, field.default_value);
        }
    }

    scr_rebuild_flag_code(_flag);
    return true;
}

function scr_set_selected_flag_type(_index)
{
    var definitions = scr_get_flag_type_definitions();
    var index = clamp(floor(real(_index)), 0, array_length(definitions) - 1);
    var definition = definitions[index];
    var flag = scr_get_selected_flag();

    global.flag_type_submenu_open = definition.key;

    if (!scr_apply_flag_type(flag, definition.key)) return false;

    mark_attack_json_dirty();
    scr_save_current_attack_json();
    return true;
}
function scr_add_flag_at_playhead(_timeline, _code = "")
{
    if (is_undefined(_timeline))
    {
        show_debug_message("Cannot add flag: timeline is undefined.");
        return undefined;
    }

    if (!variable_global_exists("current_timeline_frame"))
    {
        global.current_timeline_frame = 0;
    }

    scr_timeline_ensure_phases(_timeline);

    var key_start = max(0, round(global.current_timeline_frame));

    // If a flag already exists on this frame, select it instead

    var existing = scr_find_flag_key_at_frame(_timeline, key_start);

    if (!is_undefined(existing))
    {
        scr_clear_hitbox_selection();
        scr_clear_animation_selection();

        scr_select_flag_key(_timeline, existing.track_index, existing.key_index);
        scr_show_only_text_input_group("flag");
        scr_refresh_text_input_group("flag");

        show_debug_message("Flag already exists at frame " + string(key_start) + ". Selected existing flag.");

        return existing.key;
    }

    // Create new flag

    var track_index = scr_get_or_create_flag_track(_timeline);

    var new_flag = {
        type: "code",
        code: _code,
        scope: "frame",
        original_line: _code
    };

    var new_key = {
        start: key_start,
        duration: 1,
        phase_index: scr_timeline_get_phase_index_at_frame(_timeline, key_start),
        flag: new_flag
    };

    array_push(_timeline.tracks[track_index].keys, new_key);

    scr_sort_all_timeline_tracks(_timeline);
    scr_recalculate_timeline_total_frames(_timeline);
    scr_timeline_refresh_phase_indices(_timeline);

    scr_clear_hitbox_selection();
    scr_clear_animation_selection();

    scr_select_flag_key_by_reference(_timeline, new_key);
    scr_show_only_text_input_group("flag");
    scr_refresh_text_input_group("flag");

    mark_attack_json_dirty();
    scr_save_current_attack_json();

    show_debug_message("Added code flag at frame " + string(key_start));

    return new_key;
}
function scr_find_flag_key_at_frame(_timeline, _frame)
{
    if (is_undefined(_timeline)) return undefined;
    if (!variable_struct_exists(_timeline, "tracks")) return undefined;

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

            if (key.start == _frame)
            {
                return {
                    track_index: t,
                    key_index: k,
                    key: key
                };
            }
        }
    }

    return undefined;
}
function scr_cull_redundant_flags(_timeline)
{
    if (is_undefined(_timeline)) return 0;
    if (!is_struct(_timeline)) return 0;
    if (!variable_struct_exists(_timeline, "tracks")) return 0;

    var removed_count = 0;

    // Some attacks set animation frames from phase code instead of frame data:
    // if (attack_frame <= 10)
    //     anim_frame = 3;
    // Convert those pairs into ordinary timeline animation keys. Any unrelated
    // phase code remains in the flag.
    if (variable_struct_exists(_timeline, "phases"))
    {
        var animation_track_index = scr_get_or_create_animation_track(_timeline);
        var animation_track = _timeline.tracks[animation_track_index];

        for (var p = 0; p < array_length(_timeline.phases); p++)
        {
            var phase = _timeline.phases[p];

            if (!is_struct(phase)) continue;
            if (!variable_struct_exists(phase, "flags")) continue;

            for (var pf = array_length(phase.flags) - 1; pf >= 0; pf--)
            {
                var phase_flag = phase.flags[pf];
                var phase_code = "";

                if (is_string(phase_flag))
                {
                    phase_code = phase_flag;
                }
                else if (is_struct(phase_flag) && variable_struct_exists(phase_flag, "code"))
                {
                    phase_code = string(phase_flag.code);
                }

                var parsed = scr_parse_phase_animation_flag(phase_code);

                if (array_length(parsed.keys) <= 0) continue;

                for (var a = 0; a < array_length(parsed.keys); a++)
                {
                    var parsed_key = parsed.keys[a];
                    var countdown_frame = clamp(parsed_key.attack_frame, 0, phase.lasts);
                    var key_start = phase.start + (phase.lasts - countdown_frame);
                    var updated_existing = false;

                    // Phase code runs after the frame switch, so it overrides an
                    // animationFrame value already present at the same frame.
                    for (var ak = 0; ak < array_length(animation_track.keys); ak++)
                    {
                        var animation_key = animation_track.keys[ak];

                        if (animation_key.start == key_start)
                        {
                            animation_key.animation_frame = parsed_key.animation_frame;
                            animation_key.duration = 1;
                            animation_key.phase_index = p;
                            animation_key.source_countdown_frame = countdown_frame;
                            animation_track.keys[ak] = animation_key;
                            updated_existing = true;
                            break;
                        }
                    }

                    if (!updated_existing)
                    {
                        array_push(animation_track.keys, {
                            start: key_start,
                            duration: 1,
                            animation_frame: parsed_key.animation_frame,
                            phase_index: p,
                            source_countdown_frame: countdown_frame
                        });
                    }
                }

                if (scr_string_is_whitespace(parsed.remaining_code))
                {
                    array_delete(phase.flags, pf, 1);
                    removed_count++;
                }
                else if (is_string(phase_flag))
                {
                    phase.flags[pf] = {
                        type: "code",
                        code: parsed.remaining_code,
                        scope: "phase",
                        original_line: parsed.remaining_code
                    };
                }
                else
                {
                    phase_flag.code = parsed.remaining_code;
                }
            }
        }
    }

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        if (!is_struct(track)) continue;
        if (!variable_struct_exists(track, "type")) continue;
        if (!variable_struct_exists(track, "keys")) continue;

        if (track.type != "flag")
        {
            continue;
        }

        // Delete backwards so removing a key cannot cause the next key to be skipped.
        for (var k = array_length(track.keys) - 1; k >= 0; k--)
        {
            var key = track.keys[k];
            var code = "";

            if (is_struct(key) && variable_struct_exists(key, "flag"))
            {
                if (is_string(key.flag))
                {
                    code = key.flag;
                }
                else if (is_struct(key.flag) && variable_struct_exists(key.flag, "code"))
                {
                    code = string(key.flag.code);
                }
            }
            // Support the direct-code shape used by older timeline data.
            else if (is_struct(key) && variable_struct_exists(key, "code"))
            {
                code = string(key.code);
            }

            if (redundant_flags(code))
            {
                array_delete(track.keys, k, 1);
                removed_count++;
            }
        }
    }

    scr_sort_all_timeline_tracks(_timeline);

    return removed_count;
}

function scr_parse_phase_animation_flag(_input)
{
    var result = {
        keys: [],
        remaining_code: _input
    };

    if (!is_string(_input)) return result;

    var code = string_replace_all(_input, "\r", "");
    var lines = string_split(code, "\n");
    var remaining_lines = [];

    for (var i = 0; i < array_length(lines); i++)
    {
        var next_line = i + 1;

        // Permit blank lines between the condition and assignment.
        while (next_line < array_length(lines) && scr_string_is_whitespace(lines[next_line]))
        {
            next_line++;
        }

        var parsed_key = undefined;

        if (next_line < array_length(lines))
        {
            parsed_key = scr_parse_phase_animation_lines(lines[i], lines[next_line]);
        }

        if (!is_undefined(parsed_key))
        {
            array_push(result.keys, parsed_key);
            i = next_line;
            continue;
        }

        array_push(remaining_lines, lines[i]);
    }

    var remaining_code = "";

    for (var line_index = 0; line_index < array_length(remaining_lines); line_index++)
    {
        if (line_index > 0) remaining_code += "\n";
        remaining_code += remaining_lines[line_index];
    }

    result.remaining_code = remaining_code;
    return result;
}

function scr_parse_phase_animation_lines(_condition_line, _assignment_line)
{
    var condition = scr_remove_code_whitespace(_condition_line);
    var assignment = scr_remove_code_whitespace(_assignment_line);
    var condition_prefix = "if(attack_frame<=";
    var assignment_prefix = "anim_frame=";

    if (string_copy(condition, 1, string_length(condition_prefix)) != condition_prefix)
    {
        return undefined;
    }

    if (string_char_at(condition, string_length(condition)) != ")")
    {
        return undefined;
    }

    var attack_frame_text = string_copy(
        condition,
        string_length(condition_prefix) + 1,
        string_length(condition) - string_length(condition_prefix) - 1
    );

    if (attack_frame_text == "" || string_digits(attack_frame_text) != attack_frame_text)
    {
        return undefined;
    }

    if (string_char_at(assignment, string_length(assignment)) == ";")
    {
        assignment = string_delete(assignment, string_length(assignment), 1);
    }

    if (string_copy(assignment, 1, string_length(assignment_prefix)) != assignment_prefix)
    {
        return undefined;
    }

    var animation_frame_text = string_copy(
        assignment,
        string_length(assignment_prefix) + 1,
        string_length(assignment) - string_length(assignment_prefix)
    );

    if (animation_frame_text == "" || string_digits(animation_frame_text) != animation_frame_text)
    {
        return undefined;
    }

    return {
        attack_frame: round(real(attack_frame_text)),
        animation_frame: round(real(animation_frame_text))
    };
}

function scr_remove_code_whitespace(_input)
{
    var output = string_replace_all(_input, " ", "");
    output = string_replace_all(output, "\t", "");
    output = string_replace_all(output, "\r", "");
    output = string_replace_all(output, "\n", "");
    return output;
}

function scr_string_is_whitespace(_input)
{
    return scr_remove_code_whitespace(_input) == "";
}

function redundant_flags(_input)
{
    if (!is_string(_input)) return false;

    var redundancies = ["anim_frame", "sfx"];

    for (var i = 0; i < array_length(redundancies); i++)
    {
        if (string_pos(redundancies[i], _input) > 0)
        {
            return true;
        }
    }

    return false;
}

function scr_select_flag_key_by_reference(_timeline, _target_key)
{
    if (is_undefined(_timeline)) return false;
    if (is_undefined(_target_key)) return false;

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        if (track.type != "flag")
        {
            continue;
        }

        for (var k = 0; k < array_length(track.keys); k++)
        {
            if (track.keys[k] == _target_key)
            {
                scr_select_flag_key(_timeline, t, k);
                return true;
            }
        }
    }

    return false;
}
