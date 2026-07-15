function scr_get_hitbox_function(_hb){

	switch (_hb)
	{
		default:
            return "er"
		case 1:
			return "hitbox_create_melee"
		case 2:
			return "hitbox_create_magnetbox"
		case 3:
			return "hitbox_create_grab"
		case 4:
			return "hitbox_create_windbox"
		case 5:
			return "hitbox_create_targetbox"
	}
}

function scr_get_hitbox_create_function_from_type(_type)
{
    switch (_type)
    {
        case 0: return "hitbox_create_melee";
        case 1: return "hitbox_create_magnetbox";
        case 2: return "hitbox_create_grab";
        case 3: return "hitbox_create_windbox";
        case 4: return "hitbox_create_targetbox";
    }

    return "hitbox_create_melee";
}