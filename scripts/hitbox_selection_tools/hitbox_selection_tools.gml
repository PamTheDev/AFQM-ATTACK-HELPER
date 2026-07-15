function scr_clear_hitbox_selection()
{
    global.selected_hitbox = undefined;
    global.selected_hitbox_key = undefined;
    global.selected_hitbox_track = -1;
    global.selected_hitbox_key_index = -1;
}


function scr_select_hitbox_key(_timeline, _track_index, _key_index)
{
    if (is_undefined(_timeline))
    {
        scr_clear_hitbox_selection();
        return false;
    }

    if (_track_index < 0 || _track_index >= array_length(_timeline.tracks))
    {
        scr_clear_hitbox_selection();
        return false;
    }

    var track = _timeline.tracks[_track_index];

    if (_key_index < 0 || _key_index >= array_length(track.keys))
    {
        scr_clear_hitbox_selection();
        return false;
    }

    var key = track.keys[_key_index];

    if (track.type != "hitbox")
    {
        scr_clear_hitbox_selection();
        return false;
    }

    if (!variable_struct_exists(key, "hitbox"))
    {
        scr_clear_hitbox_selection();
        return false;
    }

    global.selected_hitbox = key.hitbox;
    global.selected_hitbox_key = key;
    global.selected_hitbox_track = _track_index;
    global.selected_hitbox_key_index = _key_index;

    return true;
}


function scr_select_hitbox_from_hitbox(_timeline, _hitbox)
{
    if (is_undefined(_timeline))
    {
        scr_clear_hitbox_selection();
        return false;
    }

    if (is_undefined(_hitbox))
    {
        scr_clear_hitbox_selection();
        return false;
    }

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

            if (key.hitbox == _hitbox)
            {
                global.selected_hitbox = _hitbox;
                global.selected_hitbox_key = key;
                global.selected_hitbox_track = t;
                global.selected_hitbox_key_index = k;

                return true;
            }
        }
    }

    scr_clear_hitbox_selection();
    return false;
}