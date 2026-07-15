function scr_find_related_attack_gml_recursive(_folder, _attack_name, _sprite_folder_name)
{
    _folder = scr_normalize_folder_path(_folder);

    var lower_attack_name = string_lower(_attack_name);
    var lower_sprite_folder_name = string_lower(_sprite_folder_name);

    var exact_name_1 = "gml_globalscript_" + lower_attack_name + ".gml";
    var exact_name_2 = "gml_globalscript_" + lower_sprite_folder_name + ".gml";

    
    // 1. Search this folder for matching GML files
    

    var file_mask = _folder + "gml_GlobalScript_*.gml";

    var found_file = file_find_first(file_mask, 0);

    while (found_file != "")
    {
        var found_path = string_replace_all(found_file, "\\", "/");

        // Some GameMaker versions return only the filename.
        if (string_pos("/", found_path) == 0)
        {
            found_path = _folder + found_path;
        }

        var found_name = scr_get_path_folder_name(found_path);
        var lower_found_name = string_lower(found_name);

        var starts_correctly = scr_starts_with(lower_found_name, "gml_globalscript_");
        var ends_correctly = scr_ends_with(lower_found_name, ".gml");

        var exact_match =
            lower_found_name == exact_name_1 ||
            lower_found_name == exact_name_2;

        var flexible_match =
            string_pos(lower_attack_name, lower_found_name) > 0 ||
            string_pos(lower_sprite_folder_name, lower_found_name) > 0;

        if (starts_correctly && ends_correctly && (exact_match || flexible_match))
        {
            file_find_close();
            return found_path;
        }

        found_file = file_find_next();
    }

    file_find_close();

    
    // 2. Collect subfolders first
    // Important: do not recurse while file_find is still active.
    

    var subfolders = [];

    var folder_mask = _folder + "*";

    var found_dir = file_find_first(folder_mask, fa_directory);

    while (found_dir != "")
    {
        var dir_path = string_replace_all(found_dir, "\\", "/");

        if (string_pos("/", dir_path) == 0)
        {
            dir_path = _folder + dir_path;
        }

        dir_path = scr_normalize_folder_path(dir_path);

        var dir_name = scr_get_path_folder_name(dir_path);

        if (dir_name != "." && dir_name != "..")
        {
            if (directory_exists(dir_path))
            {
                array_push(subfolders, dir_path);
            }
        }

        found_dir = file_find_next();
    }

    file_find_close();

    
    // 3. Search each subfolder
    

    for (var i = 0; i < array_length(subfolders); i++)
    {
        var result = scr_find_related_attack_gml_recursive(
            subfolders[i],
            _attack_name,
            _sprite_folder_name
        );

        if (result != "")
        {
            return result;
        }
    }

    return "";
}