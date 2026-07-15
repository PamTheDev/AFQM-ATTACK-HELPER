function scr_count_hitbox_tracks(_timeline)
{
    if (is_undefined(_timeline)) return 0;
    if (!variable_struct_exists(_timeline, "tracks")) return 0;

    var count = 0;

    for (var i = 0; i < array_length(_timeline.tracks); i++)
    {
        if (_timeline.tracks[i].type == "hitbox")
        {
            count += 1;
        }
    }

    return count;
}