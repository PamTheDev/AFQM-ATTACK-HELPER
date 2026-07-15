function scr_start_sprite_folder_scan()
{
    search_mask = sprite_root + "spr_*";

    show_debug_message("Sprite search mask:");
    show_debug_message(search_mask);

    found = file_find_first(search_mask, fa_directory);
    file_search_active = true;

    loader_state = "collect_folders";
    loader_text = "Scanning sprite folders...";
    loader_progress = 0.30;
}