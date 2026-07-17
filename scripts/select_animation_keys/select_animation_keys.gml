function scr_clear_animation_selection()
{
    global.selected_animation_key = undefined;
    global.selected_animation_track = -1;
    global.selected_animation_key_index = -1;
}
function scr_select_animation_key(_timeline, _track_index, _key_index)
{
    if (is_undefined(_timeline))
    {
        scr_clear_animation_selection();
        return false;
    }

    if (_track_index < 0 || _track_index >= array_length(_timeline.tracks))
    {
        scr_clear_animation_selection();
        return false;
    }

    var track = _timeline.tracks[_track_index];

    if (track.type != "animation")
    {
        scr_clear_animation_selection();
        return false;
    }

    if (_key_index < 0 || _key_index >= array_length(track.keys))
    {
        scr_clear_animation_selection();
        return false;
    }

    var key = track.keys[_key_index];

    global.selected_animation_key = key;
    global.selected_animation_track = _track_index;
    global.selected_animation_key_index = _key_index;

    return true;
}

function scr_toggle_select_animation_key(_timeline, _track_index, _key_index)
{
    if (_track_index < 0 || _track_index >= array_length(_timeline.tracks))
    {
        return false;
    }

    var track = _timeline.tracks[_track_index];

    if (track.type != "animation")
    {
        return false;
    }

    if (_key_index < 0 || _key_index >= array_length(track.keys))
    {
        return false;
    }

    var key = track.keys[_key_index];

    // Click selected animation key again to deselect it.
    if (variable_global_exists("selected_animation_key"))
    {
        if (!is_undefined(global.selected_animation_key))
        {
            if (global.selected_animation_key == key)
            {
                scr_clear_animation_selection();
                scr_hide_all_text_input_groups();
                return true;
            }
        }
    }

    // Selecting animation clears hitbox selection.
    scr_clear_hitbox_selection();
    scr_select_animation_key(_timeline, _track_index, _key_index);

    scr_show_only_text_input_group("frame");

    return true;
}