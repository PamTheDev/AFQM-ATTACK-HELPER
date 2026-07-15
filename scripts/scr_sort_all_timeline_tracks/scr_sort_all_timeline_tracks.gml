function scr_sort_all_timeline_tracks(_timeline)
{
    for (var t = 0; t < array_length(_timeline.tracks); t++)
    {
        var track = _timeline.tracks[t];
        var count = array_length(track.keys);

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
    }
}