function scr_save_attack_json_from_timeline(_timeline, _json_path)
{
    if (is_undefined(_timeline))
    {
        show_debug_message("Cannot save JSON: timeline is undefined.");
        return false;
    }

    if (_json_path == "")
    {
        show_debug_message("Cannot save JSON: json path is empty.");
        return false;
    }

    var attack_name = "unknown_attack";
    var sprite_name = "unknown_sprite";

    if (variable_global_exists("current_attack_data"))
    {
        if (!is_undefined(global.current_attack_data))
        {
            if (variable_struct_exists(global.current_attack_data, "name"))
            {
                attack_name = global.current_attack_data.name;
            }

            if (variable_struct_exists(global.current_attack_data, "sprite"))
            {
                sprite_name = global.current_attack_data.sprite;
            }
        }
    }

    var output = {
        version: 1,
        aerial: variable_struct_exists(_timeline, "aerial") && _timeline.aerial,
        sprite: sprite_name,
        name: attack_name,
        phases: []
    };

    scr_timeline_ensure_phases(_timeline);
    // Retain editor segments and empty layers while exporting runtime phases.
    output.editorTimeline = variable_clone(_timeline);
    _timeline = scr_timeline_runtime_phases(_timeline);
    scr_sort_all_timeline_tracks(_timeline);
    scr_recalculate_timeline_total_frames(_timeline);

    
    // Create JSON phases
    

    for (var p = 0; p < array_length(_timeline.phases); p++)
    {
        var timeline_phase = _timeline.phases[p];

        var phase_duration = max(1, round(timeline_phase.duration));
        var phase_lasts = max(0, phase_duration - 1);

        var json_phase = {
            smash: scr_phase_is_smash(timeline_phase),
            lasts: string(phase_lasts),
            frames: []
        };

        if (variable_struct_exists(timeline_phase, "extension_frames"))
        {
            json_phase.extensionFrames = timeline_phase.extension_frames;
            json_phase.extensionBaseLasts = timeline_phase.extension_base_lasts;
        }
        if (variable_struct_exists(timeline_phase, "or"))
        {
            json_phase.or = timeline_phase.or;
        }

        var phase_attack_stop_state = scr_get_phase_attack_stop_state(timeline_phase);

        if (phase_attack_stop_state != "none")
        {
            json_phase.attackStopState = phase_attack_stop_state;
        }

        if (variable_struct_exists(timeline_phase, "flags"))
        {
            for (var pf = 0; pf < array_length(timeline_phase.flags); pf++)
            {
                var phase_flag_data = timeline_phase.flags[pf];
                var phase_flag_code = "";

                if (is_string(phase_flag_data))
                {
                    phase_flag_code = phase_flag_data;
                }
                else if (is_struct(phase_flag_data) && variable_struct_exists(phase_flag_data, "code"))
                {
                    phase_flag_code = string(phase_flag_data.code);
                }

                if (phase_flag_code == "") continue;

                if (!variable_struct_exists(json_phase, "flags"))
                {
                    json_phase.flags = [];
                }

                array_push(json_phase.flags, {
                    type: "code",
                    code: phase_flag_code,
                    scope: "phase"
                });
            }
        }

        array_push(output.phases, json_phase);
    }

    
    // Add animation keys
    

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        if (track.type != "animation")
        {
            continue;
        }

        for (var k = 0; k < array_length(track.keys); k++)
        {
            var key = track.keys[k];

            var phase_index = scr_timeline_get_phase_index_at_frame(_timeline, key.start);
            phase_index = clamp(phase_index, 0, array_length(output.phases) - 1);

            var timeline_phase = _timeline.phases[phase_index];
            var json_phase = output.phases[phase_index];

            var local_frame = key.start - timeline_phase.start;
            local_frame = clamp(local_frame, 0, timeline_phase.duration - 1);

            var countdown_frame = timeline_phase.lasts - local_frame;

            var json_frame = scr_get_or_create_json_frame(json_phase, countdown_frame);
            json_frame.animationFrame = key.animation_frame;
        }
    }

    
    // Add hitbox keys
    

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        if (track.type != "hitbox")
        {
            continue;
        }

        for (var k = 0; k < array_length(track.keys); k++)
        {
            var key = track.keys[k];

            if (!variable_struct_exists(key, "hitbox"))
            {
                continue;
            }

            var hb = key.hitbox;

            var phase_index = scr_timeline_get_phase_index_at_frame(_timeline, key.start);
            phase_index = clamp(phase_index, 0, array_length(output.phases) - 1);

            var timeline_phase = _timeline.phases[phase_index];
            var json_phase = output.phases[phase_index];

            var local_frame = key.start - timeline_phase.start;
            local_frame = clamp(local_frame, 0, timeline_phase.duration - 1);

            var countdown_frame = timeline_phase.lasts - local_frame;

            var json_frame = scr_get_or_create_json_frame(json_phase, countdown_frame);

            hb.lasts = max(1, round(key.duration));

            // Guarantee the serialized hitbox schema includes a group, including
            // hitboxes created by older versions of the editor.
            if (!variable_struct_exists(hb, "group"))
            {
                hb.group = 0;
            }

            array_push(json_frame.hitboxes, hb);
        }
    }


    // Add flag keys
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

        if (!variable_struct_exists(key, "flag"))
        {
            continue;
        }

        if (is_undefined(key.flag))
        {
            continue;
        }

        if (!variable_struct_exists(key.flag, "code"))
        {
            key.flag.code = "";
        }

        var phase_index = scr_timeline_get_phase_index_at_frame(_timeline, key.start);
        phase_index = clamp(phase_index, 0, array_length(output.phases) - 1);

        var timeline_phase = _timeline.phases[phase_index];
        var json_phase = output.phases[phase_index];

        var flag_scope = "frame";

        if (variable_struct_exists(key.flag, "scope"))
        {
            flag_scope = key.flag.scope;
        }

        if (flag_scope == "phase")
        {
            if (!variable_struct_exists(json_phase, "flags"))
            {
                json_phase.flags = [];
            }

            array_push(json_phase.flags, {
                type: "code",
                code: key.flag.code,
                scope: "phase"
            });
        }
        else
        {
            var local_frame = key.start - timeline_phase.start;
            local_frame = clamp(local_frame, 0, timeline_phase.duration - 1);

            var countdown_frame = timeline_phase.lasts - local_frame;
            var json_frame = scr_get_or_create_json_frame(json_phase, countdown_frame);

            if (!variable_struct_exists(json_frame, "flags"))
            {
                json_frame.flags = [];
            }

            array_push(json_frame.flags, {
                type: "code",
                code: key.flag.code,
                scope: "frame"
            });
        }
    }
}

    
    // Ensure attack starts on animation frame 0
    

    if (array_length(output.phases) > 0)
    {
        var first_phase = output.phases[0];
        var first_timeline_phase = _timeline.phases[0];

        var start_countdown_frame = first_timeline_phase.lasts;

        var start_frame = scr_get_or_create_json_frame(first_phase, start_countdown_frame);

        if (!variable_struct_exists(start_frame, "animationFrame"))
        {
            start_frame.animationFrame = 0;
        }

        start_frame.animationFrame = 0;
    }

    
    // Write file
    

    var json_text = json_stringify(output);

    // libfilesystem's text writer can terminate the Windows runner when the
    // editor performs several autosaves close together. Attack JSON lives in
    // GameMaker's writable local-data area, so use the built-in buffer writer.
    var json_buffer_size = max(1, string_byte_length(json_text));
    var json_buffer = buffer_create(json_buffer_size, buffer_fixed, 1);

    buffer_write(json_buffer, buffer_text, json_text);
    buffer_save(json_buffer, _json_path);
    buffer_delete(json_buffer);

    global.current_attack_data = output;
    global.attack_json_dirty = false;

    show_debug_message("Saved attack JSON:");
    show_debug_message(_json_path);

    return true;
}
