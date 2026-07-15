function scr_find_related_attack_gml(_mod_root, _sprite_folder_name)
{
    _mod_root = scr_normalize_folder_path(_mod_root);

    var attack_name = _sprite_folder_name;

    // spr_dsmash_pulse -> dsmash_pulse
    if (scr_starts_with(attack_name, "spr_"))
    {
        attack_name = string_copy(attack_name, 5, string_length(attack_name) - 4);
    }

    show_debug_message("Looking for related GML for sprite:");
    show_debug_message(_sprite_folder_name);
    show_debug_message("Attack name:");
    show_debug_message(attack_name);

    var search_roots = [
        _mod_root,
        _mod_root + "scripts/",
        _mod_root + "Scripts/",
        _mod_root + "SCRIPTS/"
    ];

    for (var i = 0; i < array_length(search_roots); i++)
    {
        var root = scr_normalize_folder_path(search_roots[i]);

        if (!directory_exists(root))
        {
            continue;
        }

        var result = scr_find_related_attack_gml_recursive(root, attack_name, _sprite_folder_name);

        if (result != "")
        {
            show_debug_message("Related GML found:");
            show_debug_message(result);
            return result;
        }
    }

    show_debug_message("No related GML found for:");
    show_debug_message(_sprite_folder_name);

    return "";
}