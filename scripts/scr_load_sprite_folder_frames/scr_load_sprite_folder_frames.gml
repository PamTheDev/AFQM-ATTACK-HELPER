function scr_load_sprite_folder_frames(_folder_path, _sprite_folder_name)
{
    _folder_path = scr_normalize_folder_path(_folder_path);

    global.loaded_frame_sprites = [];

    var index = 0;

    while (true)
    {
        // Try 0-based filename first:
        // spr_name_0.png
        //var png_path = _folder_path + _sprite_folder_name + "_" + string(index) + ".png";
		
		var png_path = _folder_path + generate_image_name(index) + ".png";
		
        // If that does not exist, try 1-based filename:
        // spr_name_1.png
        if (!file_exists(png_path))
        {
            png_path = _folder_path + generate_image_name(index+1) + ".png";
        }

        if (!file_exists(png_path))
        {
            break;
        }

        var spr = sprite_add(png_path, 1, false, false, 0, 0);

        if (spr != -1)
        {
            // Set origin to middle center.
            var sw = sprite_get_width(spr);
            var sh = sprite_get_height(spr);

            sprite_set_offset(spr, sw * 0.5, sh * 0.5);

            array_push(global.loaded_frame_sprites, spr);
        }

        index += 1;

        if (index > 500)
        {
            break;
        }
    }

    show_debug_message("Loaded frame sprites: " + string(array_length(global.loaded_frame_sprites)));
}