// Only delete loaded frame sprites if this object owns them.
// If another object loads them, leave this empty.

if (variable_global_exists("loaded_frame_sprites"))
{
    for (var i = 0; i < array_length(global.loaded_frame_sprites); i++)
    {
        var spr = global.loaded_frame_sprites[i];

        if (spr != -1)
        {
            sprite_delete(spr);
        }
    }

    global.loaded_frame_sprites = [];
}

if (surface_exists(preview_surface))
{
    surface_free(preview_surface);
}


if (global.hitbox_creation_state == "") {
	if new_hb_x != 0
		new_hb_x = 0
		new_hb_y = 0
		new_hb_xScale = 0
		new_hb_yScale = 0
	
}