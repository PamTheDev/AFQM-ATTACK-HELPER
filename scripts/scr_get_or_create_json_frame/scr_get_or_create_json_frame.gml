function scr_get_or_create_json_frame(_phase, _countdown_frame)
{
    if (!variable_struct_exists(_phase, "frames"))
    {
        _phase.frames = [];
    }

    for (var i = 0; i < array_length(_phase.frames); i++)
    {
        if (_phase.frames[i].frame == _countdown_frame)
        {
            return _phase.frames[i];
        }
    }

    var new_frame = {
        frame: _countdown_frame,
        animationFrame: 0,
        hitboxes: []
    };

    array_push(_phase.frames, new_frame);

    return new_frame;
}