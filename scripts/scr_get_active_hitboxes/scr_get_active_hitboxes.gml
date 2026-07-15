function scr_get_active_hitboxes(_timeline, _frame)
{
    var result = [];

    for (var t = 1; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        for (var k = 0; k < array_length(track.keys); k++)
        {
            var key = track.keys[k];

            if (_frame >= key.start && _frame < key.start + key.duration)
            {
                array_push(result, key.hitbox);
            }
        }
    }

    return result;
}