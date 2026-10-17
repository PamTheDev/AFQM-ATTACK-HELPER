if (variable_global_exists("context_click_consumed") && global.context_click_consumed) exit;

global.quick_load_last_mod_cache = true;
global.use_cached_sprite_folders = false;

show_debug_message("Quick load requested.");

room_goto_next();