function scr_collect_sprite_png(_sprite_root)
{
    _sprite_root = scr_normalize_folder_path(_sprite_root);

    var pngs = [];

    // Check lowercase .pngs
    var found = file_find_first(_sprite_root + "*.png", 0);

    while (found != "")
    {
        var png_path = string_replace_all(found, "\\", "/");

        if (string_pos("/", png_path) == 0)
        {
            png_path = _sprite_root + png_path;
        }

        var file_name = scr_get_path_folder_name(png_path);
        var sprite_name = scr_remove_file_extension(file_name);

        var expected_folder = scr_normalize_folder_path(_sprite_root + sprite_name);

        if (!directory_exists(expected_folder))
        {
            array_push(pngs, png_path);

            show_debug_message("png needs conversion:");
            show_debug_message(png_path);
        }
        else
        {
            show_debug_message("Skipping png because sprite folder already exists:");
            show_debug_message(expected_folder);
        }

        found = file_find_next();
    }

    file_find_close();


    // Check uppercase .PNG
    found = file_find_first(_sprite_root + "*.PNG", 0);

    while (found != "")
    {
        var png_path_upper = string_replace_all(found, "\\", "/");

        if (string_pos("/", png_path_upper) == 0)
        {
            png_path_upper = _sprite_root + png_path_upper;
        }

        var file_name_upper = scr_get_path_folder_name(png_path_upper);
        var sprite_name_upper = scr_remove_file_extension(file_name_upper);

        var expected_folder_upper = scr_normalize_folder_path(_sprite_root + sprite_name_upper);

        if (!directory_exists(expected_folder_upper))
        {
            array_push(pngs, png_path_upper);

            show_debug_message("png needs conversion:");
            show_debug_message(png_path_upper);
        }
        else
        {
            show_debug_message("Skipping png because sprite folder already exists:");
            show_debug_message(expected_folder_upper);
        }

        found = file_find_next();
    }

    file_find_close();

    return pngs;
}