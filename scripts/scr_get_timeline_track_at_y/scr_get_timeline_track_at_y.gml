function scr_get_timeline_track_at_y(_timeline, _mouse_y, _timeline_y, _track_h, _scroll_y)
{
    var track_index = floor((_mouse_y - (_timeline_y + 24) + _scroll_y) / _track_h);

    if (track_index < 0)
    {
        return -1;
    }

    if (track_index >= array_length(_timeline.tracks))
    {
        return -1;
    }

    return track_index;
}