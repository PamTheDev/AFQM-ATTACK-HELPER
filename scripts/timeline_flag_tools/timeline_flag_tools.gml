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