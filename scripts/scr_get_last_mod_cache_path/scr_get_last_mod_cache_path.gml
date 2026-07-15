function scr_get_last_mod_cache_path()
{
    var cache_dir = scr_normalize_folder_path(game_save_id) + "mod_cache/";

    if (!directory_exists(cache_dir))
    {
        directory_create(cache_dir);
    }

    return cache_dir + "last_mod_cache.json";
}