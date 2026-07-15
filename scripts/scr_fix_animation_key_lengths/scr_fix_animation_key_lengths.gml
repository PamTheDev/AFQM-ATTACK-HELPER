function scr_fix_animation_key_lengths(_timeline)
{
    if (array_length(_timeline.tracks) <= 0)
    {
        return;
    }

    var track = _timeline.tracks[0];

    var count = array_length(track.keys);

    if (count <= 0)
    {
        return;
    }

    // Make sure animation keys are ordered first.
    for (var i = 0; i < count - 1; i++)
    {
        for (var j = 0; j < count - i - 1; j++)
        {
            if (track.keys[j].start > track.keys[j + 1].start)
            {
                var temp = track.keys[j];
                track.keys[j] = track.keys[j + 1];
                track.keys[j + 1] = temp;
            }
        }
    }

    for (var k = 0; k < count; k++)
    {
        var current_key = track.keys[k];

        if (k < count - 1)
        {
            current_key.duration = max(1, track.keys[k + 1].start - current_key.start);
        }
        else
        {
            current_key.duration = max(1, _timeline.total_frames - current_key.start);
        }
    }
}