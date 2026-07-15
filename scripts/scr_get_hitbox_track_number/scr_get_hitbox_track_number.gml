function scr_get_hitbox_track_number(_timeline, _track_index)
{
    if (is_undefined(_timeline)) return 0;
    if (!variable_struct_exists(_timeline, "tracks")) return 0;

    var hitbox_number = 0;
    var track_count = array_length(_timeline.tracks);

    _track_index = clamp(_track_index, 0, max(0, track_count - 1));

    for (var i = 0; i <= _track_index; i++)
    {
        if (_timeline.tracks[i].type == "hitbox")
        {
            hitbox_number += 1;
        }
    }

    return hitbox_number;
}