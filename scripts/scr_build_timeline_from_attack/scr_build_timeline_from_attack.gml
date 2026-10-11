function scr_build_timeline_from_attack(_attack)
{
    if (variable_struct_exists(_attack, "editorTimeline"))
    {
        var saved = variable_clone(_attack.editorTimeline);
        scr_sort_all_timeline_tracks(saved);
        scr_recalculate_timeline_total_frames(saved);
        return saved;
    }
    var timeline = {
        total_frames: 0,
        phases: [],
        tracks: []
    };

    var animation_track = {
        name: "Animation",
        type: "animation",
        keys: []
    };

    array_push(timeline.tracks, animation_track);


    // Hitbox tracks

    var hitbox_tracks = [];

    var phase_start = 0;

    for (var p = 0; p < array_length(_attack.phases); p++)
    {
        var phase = _attack.phases[p];

        var phase_lasts = 0;

        if (variable_struct_exists(phase, "lasts"))
        {
            phase_lasts = real(phase.lasts);
        }

        if (phase_lasts < 0)
        {
            phase_lasts = 0;
        }

        // Because attack_frame counts down from lasts to 0,
        // a phase with lasts = 16 has frames:
        // 16, 15, 14, ..., 0
        // That is 17 timeline frames.
        var phase_length = phase_lasts + 1;

        var phase_flags = [];

        if (variable_struct_exists(phase, "flags"))
        {
            for (var pf = 0; pf < array_length(phase.flags); pf++)
            {
                var phase_flag_data = phase.flags[pf];

                var phase_flag = phase_flag_data;

                if (is_string(phase_flag_data))
                {
                    phase_flag = {
                        type: "code",
                        code: phase_flag_data,
                        scope: "phase",
                        original_line: phase_flag_data
                    };
                }
                else
                {
                    if (!variable_struct_exists(phase_flag, "type"))
                    {
                        phase_flag.type = "code";
                    }

                    if (!variable_struct_exists(phase_flag, "code"))
                    {
                        phase_flag.code = "";
                    }

                    phase_flag.scope = "phase";
                }

                // Phase flags belong to the phase itself and are edited from
                // the phase panel. Only frame flags appear on the Flags track.
                array_push(phase_flags, phase_flag);
            }
        }


        // Frame data

        if (variable_struct_exists(phase, "frames"))
        {
            for (var f = 0; f < array_length(phase.frames); f++)
            {
                var frame_data = phase.frames[f];

                if (!variable_struct_exists(frame_data, "frame"))
                {
                    continue;
                }

                var countdown_frame = real(frame_data.frame);

                // Convert countdown attack_frame into normal left-to-right timeline frame.
                var local_timeline_frame = phase_lasts - countdown_frame;

                // Safety clamp.
                local_timeline_frame = clamp(local_timeline_frame, 0, phase_length - 1);

                var absolute_frame = phase_start + local_timeline_frame;



                if (variable_struct_exists(frame_data, "animationFrame"))
                {
                    array_push(animation_track.keys, {
                        start: absolute_frame,
                        duration: 1,
                        animation_frame: real(frame_data.animationFrame),

                        phase_index: p,
                        source_countdown_frame: countdown_frame,
                        source_frame: frame_data
                    });
                }



                if (variable_struct_exists(frame_data, "hitboxes"))
                {
                    for (var h = 0; h < array_length(frame_data.hitboxes); h++)
                    {
                        var hb = frame_data.hitboxes[h];

                        // SFX values are GML sound references/expressions. Normalize legacy
                        // numeric JSON values to strings so subsequent saves preserve the type.
                        if (variable_struct_exists(hb, "sfx"))
                        {
                            hb.sfx = string(hb.sfx);
                        }
                        else
                        {
                            hb.sfx = "";
                        }

                        // Older attack JSON may not include a hitbox group.
                        // Normalize it here so every hitbox in the editor has one.
                        if (!variable_struct_exists(hb, "group"))
                        {
                            hb.group = 0;
                        }

                        var track_index = h + 1;

                        if (variable_struct_exists(hb, "id"))
                        {
                            track_index = max(1, round(real(hb.id)));
                        }

                        while (array_length(hitbox_tracks) < track_index)
                        {
                            var new_track = {
                                name: "Track " + string(array_length(hitbox_tracks) + 1),
                                type: "hitbox",
                                keys: []
                            };

                            array_push(hitbox_tracks, new_track);
                            array_push(timeline.tracks, new_track);
                        }

                        var hitbox_track = hitbox_tracks[track_index - 1];

                        var hb_lasts = 1;

                        if (variable_struct_exists(hb, "lasts"))
                        {
                            hb_lasts = max(1, round(real(hb.lasts)));
                        }

                        array_push(hitbox_track.keys, {
                            start: absolute_frame,
                            duration: hb_lasts,

                            hitbox_id: track_index,
                            hitbox: hb,

                            phase_index: p,
                            source_countdown_frame: countdown_frame,
                            source_frame: frame_data
                        });
                    }
                }



                if (variable_struct_exists(frame_data, "flags"))
                {
                    for (var fl = 0; fl < array_length(frame_data.flags); fl++)
                    {
                        var flag_data = frame_data.flags[fl];

                        var flag = flag_data;

                        if (is_string(flag_data))
                        {
                            flag = {
                                type: "code",
                                code: flag_data,
                                scope: "frame",
                                original_line: flag_data
                            };
                        }
                        else
                        {
                            if (!variable_struct_exists(flag, "type"))
                            {
                                flag.type = "code";
                            }

                            if (!variable_struct_exists(flag, "code"))
                            {
                                flag.code = "";
                            }

                            flag.scope = "frame";
                        }

                        // Reuse a flag track when this frame is free. If every
                        // flag track is occupied here, create the next track.
                        var flag_track_index = scr_get_or_create_available_flag_track(
                            timeline,
                            absolute_frame,
                            1
                        );

                        array_push(timeline.tracks[flag_track_index].keys, {
                            start: absolute_frame,
                            duration: 1,

                            flag: flag,

                            phase_index: p,
                            source_countdown_frame: countdown_frame,
                            source_frame: frame_data
                        });
                    }
                }
            }
        }

        var phase_attack_stop_state = "none";

        if (variable_struct_exists(phase, "attackStopState"))
        {
            phase_attack_stop_state = string(phase.attackStopState);
        }

        array_push(timeline.phases, {
            name: "Phase " + string(p),
            start: phase_start,
            duration: phase_length,
            phase_index: p,
            lasts: max(0, phase_length - 1),
            flags: phase_flags,
            attack_stop_state: phase_attack_stop_state
        });

        phase_start += phase_length;
    }

    timeline.total_frames = phase_start;

    scr_sort_all_timeline_tracks(timeline);
	
	scr_cull_redundant_flags(timeline)
	
    return timeline;
}
