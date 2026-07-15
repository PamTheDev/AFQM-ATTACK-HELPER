function scr_build_timeline_from_attack(_attack)
{
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

                // IMPORTANT:
                // Convert countdown attack_frame into normal left-to-right timeline frame.
                var local_timeline_frame = phase_lasts - countdown_frame;

                // Safety clamp
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
						
                        var hb_lasts = max(1, round(real(hb.lasts)));
						
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
            }
        }

array_push(timeline.phases, {
    name: "Phase " + string(p),
    start: phase_start,
    duration: phase_length,
    phase_index: p,
    lasts: max(0, phase_length - 1)
});
        phase_start += phase_length;
    }

    timeline.total_frames = phase_start;

    scr_sort_all_timeline_tracks(timeline);
    //scr_fix_animation_key_lengths(timeline);

    return timeline;
}