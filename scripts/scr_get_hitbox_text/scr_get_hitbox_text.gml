function scr_get_hitbox_text(_hb){
	if (is_undefined(_hb))
    {
        return "er";
    }

    if (!variable_struct_exists(_hb, "hitboxCreateFunction"))
    {
        return "er";
    }

	
	switch (_hb.hitboxCreateFunction)
	{
		default:
            return "er"
		case "hitbox_create_melee":
			return "HB"
		case "hitbox_create_magnetbox":
			return "MB"
		case "hitbox_create_grab":
			return "GB"
		case "hitbox_create_windbox":
			return "WB"
		case "hitbox_create_targetbox":
			return "TB"
	}
}
