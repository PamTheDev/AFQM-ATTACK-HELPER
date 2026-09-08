function scr_timeline_ranges_overlap(_start_a, _duration_a, _start_b, _duration_b)
{
    var end_a = _start_a + _duration_a;
    var end_b = _start_b + _duration_b;

    return _start_a < end_b && end_a > _start_b;
}


function scr_timeline_hitbox_track_has_overlap(_track, _start, _duration)
{
    for (var k = 0; k < array_length(_track.keys); k++)
    {
        var key = _track.keys[k];

        if (scr_timeline_ranges_overlap(
            _start,
            _duration,
            key.start,
            key.duration
        ))
        {
            return true;
        }
    }

    return false;
}


function scr_get_or_create_available_hitbox_track(_timeline, _start, _duration)
{
    // First try existing hitbox tracks.
    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        if (track.type != "hitbox")
        {
            continue;
        }

        if (!scr_timeline_hitbox_track_has_overlap(track, _start, _duration))
        {
            return t;
        }
    }

    // No free hitbox track found, so create a new one.
    var new_track_index = array_length(_timeline.tracks);

    // Count existing hitbox tracks BEFORE adding the new one.
    var new_hitbox_number = scr_count_hitbox_tracks(_timeline) + 1;

    var new_track = {
        name: "Hitbox " + string(new_hitbox_number),
        type: "hitbox",
        keys: []
    };

    array_push(_timeline.tracks, new_track);

    show_debug_message("Created new hitbox track:");
    show_debug_message(new_track.name);

    return new_track_index;
}


function scr_add_hitbox_at_playhead(_timeline, _x, _y, _xScale, _yScale, _type)
{
    if (is_undefined(_timeline))
    {
        show_debug_message("Cannot add hitbox: timeline is undefined.");
        return undefined;
    }

    if (!variable_global_exists("current_timeline_frame"))
    {
        global.current_timeline_frame = 0;
    }

    scr_timeline_ensure_phases(_timeline);

    var key_start = max(0, round(global.current_timeline_frame));
    var key_duration = 1;

    // Find a hitbox track where this new key does not overlap.
    // If every hitbox track overlaps, this creates a new one.
    var track_index = scr_get_or_create_available_hitbox_track(
        _timeline,
        key_start,
        key_duration
    );

    if (track_index < 0)
    {
        show_debug_message("Could not find or create hitbox track.");
        return undefined;
    }

    var track = _timeline.tracks[track_index];

    var hitbox_id = scr_get_hitbox_track_number(_timeline, track_index);

    var phase_index = scr_timeline_get_phase_index_at_frame(_timeline, key_start);

    // Default new hitbox data.
    var new_hitbox = {
        id: hitbox_id,
        hitboxCreateFunction: _type,

        x: _x,
        y: _y,
        xScale: _xScale,
        yScale: _yScale,

        angle: 0,
        lasts: key_duration,

        damage: 0,
        bkb: 0,
        kbg: 0,

        vfxStyle: "",
        sfx: ""
    };

    var new_key = {
        start: key_start,
        duration: key_duration,
        phase_index: phase_index,

        hitbox_id: hitbox_id,
        hitbox: new_hitbox
    };

    array_push(track.keys, new_key);
	
    scr_sort_all_timeline_tracks(_timeline);
    scr_recalculate_timeline_total_frames(_timeline);
    scr_timeline_refresh_phase_indices(_timeline);

    // Select the newly created key and hitbox.
    var new_key_index = -1;

    for (var k = 0; k < array_length(track.keys); k++)
    {
        if (track.keys[k] == new_key)
        {
            new_key_index = k;
            break;
        }
    }

    if (new_key_index != -1)
    {
        scr_select_hitbox_key(_timeline, track_index, new_key_index);
    }
    else
    {
        global.selected_hitbox = new_hitbox;
        global.selected_hitbox_key = new_key;
        global.selected_hitbox_track = track_index;
        global.selected_hitbox_key_index = -1;
    }

    // Optional undo entry.
    if (variable_global_exists("undo_history"))
    {
        array_push(global.undo_history, {
            type: "hitbox_key_added",
            key: new_key,
            track_index: track_index
        });
    }

    // Save JSON if your save scripts exist.
    mark_attack_json_dirty();
    scr_save_current_attack_json();

    show_debug_message("Added hitbox at playhead.");
    show_debug_message("Frame: " + string(key_start));
    show_debug_message("Track: " + string(track_index));
    show_debug_message("Hitbox ID: " + string(hitbox_id));

    return new_key;
}

function scr_get_animation_track_index(_timeline)
{
    if (is_undefined(_timeline)) return -1;
    if (!variable_struct_exists(_timeline, "tracks")) return -1;

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        if (_timeline.tracks[t].type == "animation")
        {
            return t;
        }
    }

    return -1;
}


function scr_get_or_create_animation_track(_timeline)
{
    var track_index = scr_get_animation_track_index(_timeline);

    if (track_index != -1)
    {
        return track_index;
    }

    var new_track = {
        name: "Animation",
        type: "animation",
        keys: []
    };

    // Animation track should stay at the top.
    array_insert(_timeline.tracks, 0, new_track);

    return 0;
}


function scr_add_animation_frame_at_playhead(_timeline, _animation_frame)
{
    if (is_undefined(_timeline))
    {
        show_debug_message("Cannot add animation frame: timeline is undefined.");
        return undefined;
    }

    if (!variable_global_exists("current_timeline_frame"))
    {
        global.current_timeline_frame = 0;
    }

    scr_timeline_ensure_phases(_timeline);

    var key_start = max(0, round(global.current_timeline_frame));
    var track_index = scr_get_or_create_animation_track(_timeline);
    var track = _timeline.tracks[track_index];

    _animation_frame = max(0, round(_animation_frame));

    // Optional clamp to loaded sprite frames.
    if (variable_global_exists("loaded_frame_sprites"))
    {
        var frame_count = array_length(global.loaded_frame_sprites);

        if (frame_count > 0)
        {
            _animation_frame = clamp(_animation_frame, 0, frame_count - 1);
        }
    }

    // If there is already an animation key at this timeline frame,
    // update it instead of adding a duplicate.
    for (var k = 0; k < array_length(track.keys); k++)
    {
        var key = track.keys[k];

        if (key.start == key_start)
        {
            key.animation_frame = _animation_frame;
            key.duration = 1;
            key.phase_index = scr_timeline_get_phase_index_at_frame(_timeline, key_start);

            track.keys[k] = key;

            scr_sort_all_timeline_tracks(_timeline);
            scr_recalculate_timeline_total_frames(_timeline);
            scr_timeline_refresh_phase_indices(_timeline);

            mark_attack_json_dirty();
            scr_save_current_attack_json();

            show_debug_message("Updated animation key at frame " + string(key_start));
            show_debug_message("Animation frame: " + string(_animation_frame));

            return {
                track_index: track_index,
                key_index: k,
                key: key,
                updated_existing: true
            };
        }
    }

    // Create a new animation key.
    var new_key = {
        start: key_start,
        duration: 1,
        phase_index: scr_timeline_get_phase_index_at_frame(_timeline, key_start),
        animation_frame: _animation_frame
    };

    array_push(track.keys, new_key);

    scr_sort_all_timeline_tracks(_timeline);
    scr_recalculate_timeline_total_frames(_timeline);
    scr_timeline_refresh_phase_indices(_timeline);

    // Find the new key index after sorting.
    var new_key_index = -1;

    for (var i = 0; i < array_length(track.keys); i++)
    {
        if (track.keys[i] == new_key)
        {
            new_key_index = i;
            break;
        }
    }

    mark_attack_json_dirty();
    scr_save_current_attack_json();

    show_debug_message("Added animation key at frame " + string(key_start));
    show_debug_message("Animation frame: " + string(_animation_frame));

    return {
        track_index: track_index,
        key_index: new_key_index,
        key: new_key,
        updated_existing: false
    };
}
