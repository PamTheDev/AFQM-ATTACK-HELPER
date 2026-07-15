function scr_get_active_animation_frame(_timeline, _frame)
{
    if (is_undefined(_timeline))
    {
        return 0;
    }

    if (array_length(_timeline.tracks) <= 0)
    {
        return 0;
    }

    var animation_track = _timeline.tracks[0];

    if (animation_track.type != "animation")
    {
        return 0;
    }

    var active_animation_frame = 0;
    var best_start = -1;

    for (var i = 0; i < array_length(animation_track.keys); i++)
    {
        var key = animation_track.keys[i];

        if (key.start <= _frame)
        {
            if (key.start > best_start)
            {
                best_start = key.start;
                active_animation_frame = key.animation_frame;
            }
        }
    }

    return active_animation_frame;
}