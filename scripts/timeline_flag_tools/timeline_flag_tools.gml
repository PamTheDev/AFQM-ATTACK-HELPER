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
        return undefined;
    }

    if (!variable_global_exists("current_timeline_frame"))
    {
        global.current_timeline_frame = 0;
    }

    scr_timeline_ensure_phases(_timeline);

    var key_start = max(0, round(global.current_timeline_frame));
    var track_index = scr_get_or_create_flag_track(_timeline);

    var new_flag = scr_make_code_flag(_code, "frame", _code);

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

    scr_select_flag_key(_timeline, track_index, array_length(_timeline.tracks[track_index].keys) - 1);

    mark_attack_json_dirty();
    scr_save_current_attack_json();

    return new_key;
}