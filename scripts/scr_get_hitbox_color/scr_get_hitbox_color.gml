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