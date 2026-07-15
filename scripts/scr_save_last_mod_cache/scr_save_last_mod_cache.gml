function scr_save_last_mod_cache(_mod_root, _sprite_root, _sprite_folders)
{
    _mod_root = scr_normalize_folder_path(_mod_root);
    _sprite_root = scr_normalize_folder_path(_sprite_root);

    var cache = {
        version: 1,
        mod_root: _mod_root,
        sprite_root: _sprite_root,
        folders: []
    };

    for (var i = 0; i < array_length(_sprite_folders); i++)
    {
        var folder_data = _sprite_folders[i];

        var gml_path = "";

        if (variable_struct_exists(folder_data, "gml_path"))
        {
            gml_path = folder_data.gml_path;
        }
        else if (variable_struct_exists(folder_data, "related_gml_path"))
        {
            gml_path = folder_data.related_gml_path;
        }

        array_push(cache.folders, {
            name: folder_data.name,
            path: scr_normalize_folder_path(folder_data.path),
            gml_path: string_replace_all(gml_path, "\\", "/")
        });
    }

    var cache_path = scr_get_last_mod_cache_path();
    var json_text = json_stringify(cache);

    var file = file_text_open_write(cache_path);
    file_text_write_string(file, json_text);
    file_text_close(file);

    show_debug_message("Saved last mod cache:");
    show_debug_message(cache_path);
    show_debug_message("Cached mod root:");
    show_debug_message(_mod_root);
    show_debug_message("Cached folder count:");
    show_debug_message(string(array_length(cache.folders)));

    if (file_exists(cache_path))
    {
        show_debug_message("Cache file exists after save.");
    }
    else
    {
        show_debug_message("ERROR: Cache file does not exist after save.");
    }

    return file_exists(cache_path);
}