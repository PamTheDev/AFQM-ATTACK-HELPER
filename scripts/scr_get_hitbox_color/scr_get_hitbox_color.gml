function scr_get_hitbox_color(_hb){
	if (is_undefined(_hb))
    {
        return c_dkgray;
    }

    if (!variable_struct_exists(_hb, "hitboxCreateFunction"))
    {
        return c_dkgray;
    }

	
	switch (_hb.hitboxCreateFunction)
	{
		default:
            return c_dkgray;
		case "hitbox_create_melee":
			return c_red
		case "hitbox_create_magnetbox":
			return c_blue
		case "hitbox_create_grab":
			return c_orange
		case "hitbox_create_windbox":
			return c_white
		case "hitbox_create_targetbox":
			return c_fuchsia
	}
}

function scr_get_flag_color(_flag)
{
    if (is_undefined(_flag) || !is_struct(_flag))
    {
        return c_dkgray;
    }

    // Also identifies flags loaded from existing code.
    var flag_type = scr_try_infer_flag_submenu(_flag);

    switch (flag_type) {
		default:
            return c_dkgray;
		case "custom_code":
			return c_lime
		case "game_sound_play":
			return c_orange
		case "speed_set":
			return c_aqua
		case "vfx":
			return c_fuchsia
		case "hitbox_reset":
			return c_red
	}
}