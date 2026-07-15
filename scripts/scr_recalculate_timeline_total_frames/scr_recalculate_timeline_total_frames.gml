function scr_recalculate_timeline_total_frames(_timeline)
{
    if (is_undefined(_timeline))
    {
        return;
    }

    var total = 1;

    if (variable_struct_exists(_timeline, "phases"))
    {
        for (var p = 0; p < array_length(_timeline.phases); p++)
        {
            var phase = _timeline.phases[p];
            total = max(total, phase.start + phase.duration);
        }
    }

    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];

        for (var k = 0; k < array_length(track.keys); k++)
        {
            var key = track.keys[k];
            total = max(total, key.start + key.duration);
        }
    }

    _timeline.total_frames = total;
}