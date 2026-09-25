function scr_load_last_mod_cache_into_globals()
{
    var cache_path = scr_get_last_mod_cache_path();

    if (!file_exists(cache_path))
    {
        show_debug_message("No mod cache file found.");
        return false;
    }

    var file = file_text_open_read(cache_path);
    var json_text = "";

    while (!file_text_eof(file))
    {
        json_text += file_text_readln(file);
    }

    file_text_close(file);

    if (json_text == "")
    {
        show_debug_message("Mod cache file was empty.");
        return false;
    }

    var cache = json_parse(json_text);

    if (!is_struct(cache))
    {
        show_debug_message("Mod cache was not a struct.");
        return false;
    }

    if (!variable_struct_exists(cache, "mod_root"))
    {
        show_debug_message("Mod cache missing mod_root.");
        return false;
    }

    if (!variable_struct_exists(cache, "sprite_root"))
    {
        show_debug_message("Mod cache missing sprite_root.");
        return false;
    }

    if (!variable_struct_exists(cache, "folders"))
    {
        show_debug_message("Mod cache missing folders.");
        return false;
    }

    var mod_root = scr_normalize_folder_path(cache.mod_root);
    var sprite_root = scr_normalize_folder_path(cache.sprite_root);

    if (!directory_exists(mod_root))
    {
        show_debug_message("Cached mod root no longer exists:");
        show_debug_message(mod_root);
        return false;
    }

    if (!directory_exists(sprite_root))
    {
        show_debug_message("Cached sprite root no longer exists:");
        show_debug_message(sprite_root);
        return false;
    }

    global.mod_root = mod_root;
    global.sprite_root = sprite_root;
    global.sprite_folders = [];
    global.sprite_folder_count = 0;

    for (var i = 0; i < array_length(cache.folders); i++)
    {
        var folder_data = cache.folders[i];

        if (!variable_struct_exists(folder_data, "name")) continue;
        if (!variable_struct_exists(folder_data, "path")) continue;
        if (!variable_struct_exists(folder_data, "gml_path")) continue;

        var gml_path = string_replace_all(folder_data.gml_path, "\\", "/");

        if (!file_exists(gml_path))
        {
            show_debug_message("Skipping cached folder because GML is missing:");
            show_debug_message(gml_path);
            continue;
        }

        if (!scr_is_attack_gml(gml_path))
        {
            show_debug_message("Skipping cached GML because it is not an attack:");
            show_debug_message(gml_path);
            continue;
        }

        var attack_name = scr_get_attack_key_from_gml_path(gml_path);
        var folder_name = "spr_" + attack_name;
        var folder_path = scr_normalize_folder_path(sprite_root + folder_name);

        if (attack_name == "")
        {
            show_debug_message("Skipping cached attack because its filename has no attack name:");
            show_debug_message(gml_path);
            continue;
        }

        if (!directory_exists(folder_path))
        {
            show_debug_message("Cached attack has no sprite folder; its button will still be created:");
            show_debug_message(folder_path);
        }

        array_push(global.sprite_folders, {
            name: folder_name,
            path: folder_path,
            gml_path: gml_path,
            attack_name: attack_name
        });
    }

    global.sprite_folder_count = array_length(global.sprite_folders);

    if (global.sprite_folder_count <= 0)
    {
        show_debug_message("Cached mod had no valid attacks.");
        return false;
    }

    global.use_cached_sprite_folders = true;

    show_debug_message("Loaded cached mod:");
    show_debug_message(global.mod_root);
    show_debug_message("Cached valid attacks:");
    show_debug_message(string(global.sprite_folder_count));

    return true;
}
