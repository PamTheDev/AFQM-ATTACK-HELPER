function scr_get_active_hitboxes(_timeline, _frame)
{
    var result = [];

    if (is_undefined(_timeline))
    {
        return result;
    }

    if (!variable_struct_exists(_timeline, "tracks"))
    {
        return result;
    }

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        // IMPORTANT:
        // Only hitbox tracks can contain hitbox keys.
        if (!variable_struct_exists(track, "type"))
        {
            continue;
        }

        if (track.type != "hitbox")
        {
            continue;
        }

        if (!variable_struct_exists(track, "keys"))
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

            var key_start = key.start;
            var key_end = key.start + key.duration;

            if (_frame >= key_start && _frame < key_end)
            {
                array_push(result, key.hitbox);
            }
        }
    }

    return result;
}