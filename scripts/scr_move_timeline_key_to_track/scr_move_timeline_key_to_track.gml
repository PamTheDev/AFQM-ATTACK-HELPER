function scr_move_timeline_key_to_track(_timeline, _key, _from_track_index, _to_track_index)
{
    if (_from_track_index == _to_track_index)
    {
        return false;
    }

    if (_from_track_index < 0 || _from_track_index >= array_length(_timeline.tracks))
    {
        return false;
    }

    if (_to_track_index < 0 || _to_track_index >= array_length(_timeline.tracks))
    {
        return false;
    }

    var from_track = _timeline.tracks[_from_track_index];
    var to_track = _timeline.tracks[_to_track_index];

    if (from_track.type != "hitbox")
    {
        return false;
    }

    if (to_track.type != "hitbox")
    {
        return false;
    }

    var key_index = -1;

    for (var i = 0; i < array_length(from_track.keys); i++)
    {
        if (from_track.keys[i] == _key)
        {
            key_index = i;
            break;
        }
    }

    if (key_index == -1)
    {
        return false;
    }

    array_delete(from_track.keys, key_index, 1);
    array_push(to_track.keys, _key);

    var new_hitbox_id = scr_get_hitbox_track_number(_timeline, _to_track_index);

    if (variable_struct_exists(_key, "hitbox_id"))
    {
        _key.hitbox_id = new_hitbox_id;
    }

    if (variable_struct_exists(_key, "hitbox"))
    {
        if (!is_undefined(_key.hitbox))
        {
            _key.hitbox.id = new_hitbox_id;
        }
    }

    return true;
}