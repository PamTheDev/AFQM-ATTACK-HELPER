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
