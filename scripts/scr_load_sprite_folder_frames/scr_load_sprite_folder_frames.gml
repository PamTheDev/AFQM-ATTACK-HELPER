function scr_load_sprite_folder_frames(_folder_path, _sprite_folder_name)
{
    _folder_path = scr_normalize_folder_path(_folder_path);

    global.loaded_frame_sprites = [];

    // Sprite folders are found in two formats:
    //   spr_wizard_bair_0.png, spr_wizard_bair_1.png, ...
    //   0000.png, 0001.png, ...
    // Some older folders are also 1-based. Pick one convention up front so a
    // 1-based sequence does not load its first image twice.
    var filename_mode = "";
    var filename_index_offset = 0;

    if (file_exists(_folder_path + _sprite_folder_name + "_0.png"))
    {
        filename_mode = "named";
    }
    else if (file_exists(_folder_path + _sprite_folder_name + "_1.png"))
    {
        filename_mode = "named";
        filename_index_offset = 1;
    }
    else if (file_exists(_folder_path + generate_image_name(0) + ".png"))
    {
        filename_mode = "numeric";
    }
    else if (file_exists(_folder_path + generate_image_name(1) + ".png"))
    {
        filename_mode = "numeric";
        filename_index_offset = 1;
    }

    if (filename_mode == "")
    {
        show_debug_message("No sprite frames found in folder:");
        show_debug_message(_folder_path);
        return false;
    }

    var index = 0;

    while (true)
    {
        var file_index = index + filename_index_offset;
        var png_path = "";

        if (filename_mode == "named")
        {
            png_path = _folder_path + _sprite_folder_name + "_" + string(file_index) + ".png";
        }
        else
        {
            png_path = _folder_path + generate_image_name(file_index) + ".png";
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

    show_debug_message("Sprite filename mode: " + filename_mode);
    show_debug_message("Loaded frame sprites: " + string(array_length(global.loaded_frame_sprites)));

    return array_length(global.loaded_frame_sprites) > 0;
}
