function scr_timeline_ensure_phases(_timeline)
{
    if (is_undefined(_timeline)) return;

    if (!variable_struct_exists(_timeline, "phases"))
    {
        _timeline.phases = [];
    }

    if (array_length(_timeline.phases) <= 0)
    {
        var len = 1;

        if (variable_struct_exists(_timeline, "total_frames"))
        {
            len = max(1, _timeline.total_frames);
        }

        array_push(_timeline.phases, {
            name: "Phase 0",
            start: 0,
            duration: len,
            phase_index: 0,
            lasts: max(0, len - 1),
            flags: [],
            attack_stop_state: "none"
        });
    }
}


function scr_timeline_get_phase_index_at_frame(_timeline, _frame)
{
    scr_timeline_ensure_phases(_timeline);

    for (var i = 0; i < array_length(_timeline.phases); i++)
    {
        var phase = _timeline.phases[i];

        var phase_start = phase.start;
        var phase_end = phase.start + phase.duration;

        if (_frame >= phase_start && _frame < phase_end)
        {
            return i;
        }
    }

    return max(0, array_length(_timeline.phases) - 1);
}

function scr_timeline_shift_keys_from_frame(_timeline, _start_frame, _delta)
{
    if (_delta == 0)
    {
        return;
    }

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        for (var k = 0; k < array_length(track.keys); k++)
        {
            var key = track.keys[k];

            if (key.start >= _start_frame)
            {
                key.start += _delta;
                key.start = max(0, key.start);
            }
        }
    }
}


function scr_timeline_refresh_phase_indices(_timeline)
{
    scr_timeline_ensure_phases(_timeline);

    for (var i = 0; i < array_length(_timeline.phases); i++)
    {
        var phase = _timeline.phases[i];

        phase.phase_index = i;

        if (!variable_struct_exists(phase, "name"))
        {
            phase.name = "Phase " + string(i);
        }

        if (!variable_struct_exists(phase, "duration"))
        {
            phase.duration = 1;
        }

        phase.duration = max(1, round(phase.duration));
        phase.lasts = max(0, phase.duration - 1);

        if (!variable_struct_exists(phase, "flags"))
        {
            phase.flags = [];
        }

        _timeline.phases[i] = phase;
    }

    // Cosmetic phase update:
    // Keys stay at the same absolute timeline frame.
    // Only update their phase_index metadata.
    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        for (var k = 0; k < array_length(track.keys); k++)
        {
            var key = track.keys[k];
            key.phase_index = scr_timeline_get_phase_index_at_frame(_timeline, key.start);
        }
    }
}


function scr_timeline_resize_phase_right(_timeline, _phase_index, _new_duration)
{
    scr_timeline_ensure_phases(_timeline);

    if (_phase_index < 0) return false;
    if (_phase_index >= array_length(_timeline.phases)) return false;

    _new_duration = max(1, round(_new_duration));

    var phase = _timeline.phases[_phase_index];

    var old_duration = phase.duration;
    var delta = _new_duration - old_duration;

    if (delta == 0)
    {
        return true;
    }

    phase.duration = _new_duration;
    phase.lasts = max(0, _new_duration - 1);

    _timeline.phases[_phase_index] = phase;

    // Cosmetic phases:
    // Shift later PHASE BRACKETS only.
    // Do NOT shift timeline keys.
    for (var i = _phase_index + 1; i < array_length(_timeline.phases); i++)
    {
        _timeline.phases[i].start += delta;
    }

    scr_timeline_refresh_phase_indices(_timeline);
    scr_recalculate_timeline_total_frames(_timeline);

    // Update global.current_attack_data.phases[p].lasts
    scr_sync_json_phase_lasts_from_timeline(_timeline);

    return true;
}


function scr_timeline_resize_phase_left(_timeline, _phase_index, _new_left_frame)
{
    scr_timeline_ensure_phases(_timeline);

    if (_phase_index <= 0) return false;
    if (_phase_index >= array_length(_timeline.phases)) return false;

    var prev_phase = _timeline.phases[_phase_index - 1];

    var new_prev_duration = _new_left_frame - prev_phase.start;
    new_prev_duration = max(1, round(new_prev_duration));

    return scr_timeline_resize_phase_right(
        _timeline,
        _phase_index - 1,
        new_prev_duration
    );
}


function scr_timeline_add_phase_after(_timeline, _phase_index, _duration)
{
    scr_timeline_ensure_phases(_timeline);

    _duration = max(1, round(_duration));

    var insert_index = _phase_index + 1;

    if (_phase_index < 0)
    {
        insert_index = 0;
    }

    insert_index = clamp(insert_index, 0, array_length(_timeline.phases));

    var insert_start = 0;

    if (insert_index > 0)
    {
        var prev_phase = _timeline.phases[insert_index - 1];
        insert_start = prev_phase.start + prev_phase.duration;
    }

    // Cosmetic phases:
    // Shift later phase brackets only.
    // Do NOT shift timeline keys.
    for (var i = insert_index; i < array_length(_timeline.phases); i++)
    {
        _timeline.phases[i].start += _duration;
    }

    var new_phase = {
        name: "Phase " + string(insert_index),
        start: insert_start,
        duration: _duration,
        phase_index: insert_index,
        lasts: max(0, _duration - 1),
        flags: [],
        attack_stop_state: "none"
    };

    array_insert(_timeline.phases, insert_index, new_phase);

    scr_timeline_refresh_phase_indices(_timeline);
    scr_recalculate_timeline_total_frames(_timeline);

    // Update JSON phase count and lasts.
    scr_sync_json_phase_lasts_from_timeline(_timeline);

    return insert_index;
}


function scr_timeline_merge_phase_with_next(_timeline, _phase_index)
{
    scr_timeline_ensure_phases(_timeline);

    if (_phase_index < 0) return false;
    if (_phase_index >= array_length(_timeline.phases) - 1) return false;

    var phase = _timeline.phases[_phase_index];
    var next_phase = _timeline.phases[_phase_index + 1];

    if (!variable_struct_exists(phase, "flags")) phase.flags = [];

    if (variable_struct_exists(next_phase, "flags"))
    {
        for (var f = 0; f < array_length(next_phase.flags); f++)
        {
            array_push(phase.flags, next_phase.flags[f]);
        }
    }

    phase.duration += next_phase.duration;
    phase.lasts = max(0, phase.duration - 1);

    _timeline.phases[_phase_index] = phase;

    array_delete(_timeline.phases, _phase_index + 1, 1);

    scr_timeline_refresh_phase_indices(_timeline);
    scr_recalculate_timeline_total_frames(_timeline);

    // Update JSON phase count and lasts.
    scr_sync_json_phase_lasts_from_timeline(_timeline);

    return true;
}


function scr_draw_timeline_phase_tags(_timeline, _scroll_x, _frame_w, _content_w, _label_h, _bracket_h, _selected_phase)
{
    scr_timeline_ensure_phases(_timeline);

    var bracket_y = _label_h + 2;
    var bracket_bottom = bracket_y + _bracket_h;

    for (var i = 0; i < array_length(_timeline.phases); i++)
    {
        var phase = _timeline.phases[i];

        var px = phase.start * _frame_w - _scroll_x;
        var pw = phase.duration * _frame_w;

        if (px + pw < 0)
        {
            continue;
        }

        if (px > _content_w)
        {
            continue;
        }

        var phase_color = c_aqua;

        if (i == _selected_phase)
        {
            phase_color = c_yellow;
        }

        draw_set_alpha(0.20);
        draw_set_color(phase_color);
        draw_rectangle(px, bracket_y+5, px + pw, bracket_bottom, false);
        draw_set_alpha(1);

        draw_set_color(phase_color);

        // Bracket shape
        draw_line(px, bracket_y+5, px, bracket_bottom);
        draw_line(px, bracket_y+5, px + pw, bracket_y);
        draw_line(px + pw, bracket_y, px + pw, bracket_bottom);

        // Resize handles
        draw_rectangle(px - 2, bracket_y+5, px + 2, bracket_bottom, false);
        draw_rectangle(px + pw - 2, bracket_y, px + pw + 2, bracket_bottom, false);

        // Name above bracket
        draw_set_color(c_white);
        draw_text(px + 4, 0, phase.name);
    }

    draw_set_alpha(1);
}

function scr_sync_json_phase_lasts_from_timeline(_timeline)
{
    if (is_undefined(_timeline)) return false;

    if (!variable_global_exists("current_attack_data"))
    {
        return false;
    }

    if (is_undefined(global.current_attack_data))
    {
        return false;
    }

    if (!variable_struct_exists(global.current_attack_data, "phases"))
    {
        global.current_attack_data.phases = [];
    }

    scr_timeline_ensure_phases(_timeline);

    // Make sure JSON has the same number of phase objects.
    while (array_length(global.current_attack_data.phases) < array_length(_timeline.phases))
    {
        array_push(global.current_attack_data.phases, {
            lasts: "0",
            frames: []
        });
    }

    // Remove extra JSON phases if timeline phases were merged/deleted.
    while (array_length(global.current_attack_data.phases) > array_length(_timeline.phases))
    {
        array_delete(
            global.current_attack_data.phases,
            array_length(global.current_attack_data.phases) - 1,
            1
        );
    }

    // Sync timeline phase lasts into JSON phase lasts.
    for (var p = 0; p < array_length(_timeline.phases); p++)
    {
        var timeline_phase = _timeline.phases[p];
        var json_phase = global.current_attack_data.phases[p];

        var phase_duration = max(1, round(timeline_phase.duration));
        var phase_lasts = max(0, phase_duration - 1);

        timeline_phase.duration = phase_duration;
        timeline_phase.lasts = phase_lasts;
        _timeline.phases[p] = timeline_phase;

        json_phase.lasts = string(phase_lasts);

        if (!variable_struct_exists(json_phase, "frames"))
        {
            json_phase.frames = [];
        }

        global.current_attack_data.phases[p] = json_phase;
    }

    global.attack_json_dirty = true;

    return true;
}


function scr_get_selected_phase()
{
    if (!variable_global_exists("timeline")) return undefined;
    if (!variable_global_exists("selected_phase_index")) return undefined;

    var phase_index = global.selected_phase_index;

    if (phase_index < 0) return undefined;
    if (phase_index >= array_length(global.timeline.phases)) return undefined;

    return global.timeline.phases[phase_index];
}


function scr_get_phase_flags_code(_phase)
{
    if (is_undefined(_phase)) return "";

    if (!variable_struct_exists(_phase, "flags"))
    {
        _phase.flags = [];
    }

    var result = "";

    for (var i = 0; i < array_length(_phase.flags); i++)
    {
        var flag_data = _phase.flags[i];
        var flag_code = "";

        if (is_string(flag_data))
        {
            flag_code = flag_data;
        }
        else if (is_struct(flag_data) && variable_struct_exists(flag_data, "code"))
        {
            flag_code = string(flag_data.code);
        }

        if (flag_code == "") continue;

        if (result != "") result += "\n";
        result += flag_code;
    }

    return result;
}


function scr_set_phase_flags_code(_phase, _code, _type = "code")
{
    if (is_undefined(_phase)) return false;
	
    _code = string(_code);
    _phase.flags = [];
	_type = string(_type);
	
    if (_code != "")
    {
        array_push(_phase.flags, {
            type: _type,
            code: _code,
            scope: "phase",
            original_line: _code
        });
    }

    return true;
}


function scr_get_attack_connected_check_functions()
{
    return [
		"check_hit_cancel",
        "check_aerial",
        "check_drop_through",
        "check_jump",
        "check_landing",
        "check_walk",
        "cancel_air_check",
        "cancel_jump_check"
    ];
}


function scr_get_phase_attack_stop_states()
{
    return [
        "none",
        "idle",
        "crouching",
        "walking",
        "walk_turnaround",
        "dashing",
        "running",
        "run_turnaround",
        "run_stop",
        "jumpsquat",
        "aerial",
        "airdodging",
        "wavelanding",
        "rolling",
        "shielding",
        "shield_release",
        "shield_break",
        "parry_press",
        "parry_stun",
        "spot_dodging",
        "hitlag",
        "hitstun",
        "tumble",
        "helpless",
        "magnetized",
        "flinch",
        "balloon",
        "landing_lag",
        "knockdown",
        "getup",
        "tech_rolling",
        "teching",
        "tech_wall_jump",
        "ledge_snap",
        "ledge_hang",
        "ledge_getup",
        "ledge_jump",
        "ledge_roll",
        "ledge_attack",
        "ledge_tether",
        "ledge_trump",
        "wall_cling",
        "wall_jump",
        "knocked_out",
        "star_ko",
        "screen_ko",
        "respawning",
        "attacking",
        "grabbing",
        "grabbed",
        "grab_release",
        "lost",
        "entrance"
    ];
}


function scr_get_phase_attack_stop_state(_phase)
{
    if (is_undefined(_phase)) return "none";
    if (!variable_struct_exists(_phase, "attack_stop_state")) return "none";

    var phase_end_state = string(_phase.attack_stop_state);
    var valid_states = scr_get_phase_attack_stop_states();

    for (var i = 0; i < array_length(valid_states); i++)
    {
        if (valid_states[i] == phase_end_state) return phase_end_state;
    }

    return "none";
}


function scr_set_phase_attack_stop_state(_phase, _phase_end_state)
{
    if (is_undefined(_phase)) return false;

    var valid_states = scr_get_phase_attack_stop_states();
    var normalized_state = "none";

    for (var i = 0; i < array_length(valid_states); i++)
    {
        if (valid_states[i] == string(_phase_end_state))
        {
            normalized_state = valid_states[i];
            break;
        }
    }

    _phase.attack_stop_state = normalized_state;
    return true;
}


function scr_get_other_attack_connected_check_functions(){
	return [
        "check_crouch",
        "check_dash",
        "check_parried",
        "check_rolling",
        "check_rolling_hold",
        "check_run_stop",
        "check_tech",
        "check_wall_cling",
        "check_wall_jump",
        "check_waveland",
        "cancel_any_action_check",
        "cancel_charge_check",
        "cancel_dash_check",
        "cancel_ground_check"
    ];
}

function scr_phase_compact_code_line(_line)
{
    var compact = string_replace_all(string(_line), " ", "");
    compact = string_replace_all(compact, "\t", "");
    compact = string_replace_all(compact, "\r", "");
    compact = string_replace_all(compact, "\n", "");
    return compact;
}


function scr_phase_line_is_blank(_line)
{
    return scr_phase_compact_code_line(_line) == "";
}


function scr_phase_count_line_braces(_line)
{
    var balance = 0;

    for (var i = 1; i <= string_length(_line); i++)
    {
        var character = string_char_at(_line, i);

        if (character == "{") balance++;
        if (character == "}") balance--;
    }

    return balance;
}


function scr_phase_find_matching_brace(_lines, _open_line)
{
    var brace_depth = 0;

    for (var i = _open_line; i < array_length(_lines); i++)
    {
        brace_depth += scr_phase_count_line_braces(_lines[i]);

        if (brace_depth == 0)
        {
            return i;
        }
    }

    return -1;
}


function scr_phase_find_attack_connected_block(_lines)
{
    for (var i = 0; i < array_length(_lines); i++)
    {
        if (scr_phase_compact_code_line(_lines[i]) != "if(attack_connected())")
        {
            continue;
        }

        var open_line = i + 1;

        while (open_line < array_length(_lines) && scr_phase_line_is_blank(_lines[open_line]))
        {
            open_line++;
        }

        if (open_line >= array_length(_lines)) continue;
        if (scr_phase_compact_code_line(_lines[open_line]) != "{") continue;

        var close_line = scr_phase_find_matching_brace(_lines, open_line);

        if (close_line > open_line)
        {
            return {
                if_line: i,
                open_line: open_line,
                close_line: close_line
            };
        }
    }

    return undefined;
}


function scr_phase_get_check_function_index(_condition_line, _functions)
{
    var condition = scr_phase_compact_code_line(_condition_line);

    for (var i = 0; i < array_length(_functions); i++)
    {
        if (condition == "if(" + _functions[i] + "())")
        {
            return i;
        }
    }

    return -1;
}


function scr_get_phase_attack_connected_check_states(_phase)
{
    var functions = scr_get_attack_connected_check_functions();
    var states = array_create(array_length(functions), false);

    if (is_undefined(_phase)) return states;

    var code = string_replace_all(scr_get_phase_flags_code(_phase), "\r", "");
    var lines = string_split(code, "\n");
    var block = scr_phase_find_attack_connected_block(lines);

    if (is_undefined(block)) return states;

    for (var i = block.open_line + 1; i < block.close_line; i++)
    {
        var function_index = scr_phase_get_check_function_index(lines[i], functions);

        if (function_index >= 0)
        {
            states[function_index] = true;
        }
    }

    return states;
}


function scr_phase_join_code_lines(_lines)
{
    var result = "";

    for (var i = 0; i < array_length(_lines); i++)
    {
        if (i > 0) result += "\n";
        result += _lines[i];
    }

    return result;
}


function scr_phase_join_trimmed_code_lines(_lines)
{
    var first_line = 0;
    var last_line = array_length(_lines) - 1;

    while (first_line <= last_line && scr_phase_line_is_blank(_lines[first_line]))
    {
        first_line++;
    }

    while (last_line >= first_line && scr_phase_line_is_blank(_lines[last_line]))
    {
        last_line--;
    }

    var trimmed_lines = [];

    for (var i = first_line; i <= last_line; i++)
    {
        array_push(trimmed_lines, _lines[i]);
    }

    return scr_phase_join_code_lines(trimmed_lines);
}


function scr_get_phase_attack_connected_block_code(_phase)
{
    if (is_undefined(_phase)) return "";

    var code = string_replace_all(scr_get_phase_flags_code(_phase), "\r", "");
    var lines = string_split(code, "\n");
    var block = scr_phase_find_attack_connected_block(lines);

    if (is_undefined(block)) return "";

    var block_lines = [];

    for (var i = block.if_line; i <= block.close_line; i++)
    {
        array_push(block_lines, lines[i]);
    }

    return scr_phase_join_trimmed_code_lines(block_lines);
}


function scr_get_phase_editor_code(_phase)
{
    if (is_undefined(_phase)) return "";

    var code = string_replace_all(scr_get_phase_flags_code(_phase), "\r", "");
    var lines = string_split(code, "\n");
    var block = scr_phase_find_attack_connected_block(lines);

    if (is_undefined(block)) return code;

    var visible_lines = [];

    for (var i = 0; i < array_length(lines); i++)
    {
        if (i >= block.if_line && i <= block.close_line) continue;
        array_push(visible_lines, lines[i]);
    }

    return scr_phase_join_trimmed_code_lines(visible_lines);
}


function scr_set_phase_editor_code(_phase, _visible_code)
{
    if (is_undefined(_phase)) return false;

    var attack_connected_code = scr_get_phase_attack_connected_block_code(_phase);
    var combined_code = string(_visible_code);

    if (!scr_phase_line_is_blank(attack_connected_code))
    {
        if (!scr_phase_line_is_blank(combined_code))
        {
            combined_code += "\n\n";
        }
        else
        {
            combined_code = "";
        }

        combined_code += attack_connected_code;
    }

    return scr_set_phase_flags_code(_phase, combined_code, "code");
}


function scr_set_phase_attack_connected_checks(_phase, _states)
{
    if (is_undefined(_phase)) return false;

    var functions = scr_get_attack_connected_check_functions();

    if (!is_array(_states)) return false;
    if (array_length(_states) != array_length(functions)) return false;

    var code = string_replace_all(scr_get_phase_flags_code(_phase), "\r", "");
    var lines = string_split(code, "\n");
    var block = scr_phase_find_attack_connected_block(lines);
    var selected_count = 0;

    for (var i = 0; i < array_length(_states); i++)
    {
        if (_states[i]) selected_count++;
    }

    // No existing block and no enabled checks means there is nothing to edit.
    if (is_undefined(block) && selected_count <= 0)
    {
        return true;
    }

    var output_lines = [];

    if (is_undefined(block))
    {
        for (var i = 0; i < array_length(lines); i++)
        {
            array_push(output_lines, lines[i]);
        }

        if (!scr_phase_line_is_blank(code))
        {
            array_push(output_lines, "");
        }

        array_push(output_lines, "if (attack_connected())");
        array_push(output_lines, "{");

        for (var i = 0; i < array_length(functions); i++)
        {
            if (!_states[i]) continue;

            if (array_length(output_lines) > 2 && output_lines[array_length(output_lines) - 1] != "{")
            {
                array_push(output_lines, "");
            }

            array_push(output_lines, "    if (" + functions[i] + "())");
            array_push(output_lines, "    {");
            array_push(output_lines, "        run = false;");
            array_push(output_lines, "        exit;");
            array_push(output_lines, "    }");
        }

        array_push(output_lines, "}");
    }
    else
    {
        var remove_lines = array_create(array_length(lines), false);

        // Mark only supported check blocks for replacement. Unsupported or
        // custom attack-connected code is left untouched.
        for (var i = block.open_line + 1; i < block.close_line; i++)
        {
            if (scr_phase_get_check_function_index(lines[i], functions) < 0) continue;

            var open_line = i + 1;

            while (open_line < block.close_line && scr_phase_line_is_blank(lines[open_line]))
            {
                open_line++;
            }

            if (open_line >= block.close_line) continue;
            if (scr_phase_compact_code_line(lines[open_line]) != "{") continue;

            var close_line = scr_phase_find_matching_brace(lines, open_line);

            if (close_line <= open_line || close_line > block.close_line) continue;

            for (var remove_index = i; remove_index <= close_line; remove_index++)
            {
                remove_lines[remove_index] = true;
            }

            i = close_line;
        }

        var preserved_inner = [];
        var preserved_has_code = false;

        for (var i = block.open_line + 1; i < block.close_line; i++)
        {
            if (remove_lines[i]) continue;

            array_push(preserved_inner, lines[i]);

            if (!scr_phase_line_is_blank(lines[i]))
            {
                preserved_has_code = true;
            }
        }

        for (var i = 0; i < block.if_line; i++)
        {
            array_push(output_lines, lines[i]);
        }

        if (preserved_has_code || selected_count > 0)
        {
            for (var i = block.if_line; i <= block.open_line; i++)
            {
                array_push(output_lines, lines[i]);
            }

            for (var i = 0; i < array_length(preserved_inner); i++)
            {
                array_push(output_lines, preserved_inner[i]);
            }

            var outer_indent = scr_get_line_indent(lines[block.if_line]);
            var check_indent = outer_indent + "    ";
            var body_indent = check_indent + "    ";

            for (var i = 0; i < array_length(functions); i++)
            {
                if (!_states[i]) continue;

                if (array_length(output_lines) > 0 && !scr_phase_line_is_blank(output_lines[array_length(output_lines) - 1]))
                {
                    array_push(output_lines, "");
                }

                array_push(output_lines, check_indent + "if (" + functions[i] + "())");
                array_push(output_lines, check_indent + "{");
                array_push(output_lines, body_indent + "run = false;");
                array_push(output_lines, body_indent + "exit;");
                array_push(output_lines, check_indent + "}");
            }

            array_push(output_lines, lines[block.close_line]);
        }

        for (var i = block.close_line + 1; i < array_length(lines); i++)
        {
            array_push(output_lines, lines[i]);
        }
    }

    var output_code = scr_phase_join_code_lines(output_lines);

    if (scr_phase_line_is_blank(output_code))
    {
        output_code = "";
    }

    return scr_set_phase_flags_code(_phase, output_code, "code");
}
