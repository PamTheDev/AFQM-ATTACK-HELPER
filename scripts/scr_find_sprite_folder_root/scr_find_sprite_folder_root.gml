function scr_find_sprite_folder_root(_mod_root)
{
    _mod_root = scr_normalize_folder_path(_mod_root);

    var candidates = [
        _mod_root + "Sprites/",
        _mod_root + "sprites/",
        _mod_root + "SPRITES/",
        _mod_root
    ];

    for (var i = 0; i < array_length(candidates); i++)
    {
        if (directory_exists(candidates[i]))
        {
            return candidates[i];
        }
    }

    return "";
}