function scr_hitbox_states_equal(_a, _b)
{
    return
        _a.x == _b.x &&
        _a.y == _b.y &&
        _a.xScale == _b.xScale &&
        _a.yScale == _b.yScale;
}