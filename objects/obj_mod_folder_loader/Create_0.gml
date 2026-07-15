// obj_mod_folder_loader Create Event

show_debug_message("obj_mod_folder_loader CREATE");

with (obj_sprite_folder_button)
{
    instance_destroy();
}


// Basic variables


global.loading_sprite_buttons = true;

loader_state = "";
last_loader_state = "";

load_progress = 0;
load_text = "Starting...";
load_error = "";

// Paths
mod_root = "";
sprite_root = "";
search_mask = "";

// GIF conversion
gif_files = [];
gif_index = 0;
gif_conversion_started = false;
gif_wait_frames = 0;
gif_wait_max = room_speed * 120;

// Folder scanning
found = "";
file_search_active = false;
found_sprite_folders = [];
scan_per_step = 40;

// GML matching
valid_index = 0;
gml_checks_per_step = 1;

// Button creation
create_index = 0;
buttons_per_step = 8;

// Layout
button_start_x = 64;
button_start_y = 56;
button_w = 230;
button_h = 40;
button_gap_x = 8;
button_gap_y = 8;
buttons_per_column = 14;

done_timer = 30;



// QUICK LOAD CACHE CHECK
// This must happen BEFORE clearing global.sprite_folders.


var quick_load_requested = false;

if (variable_global_exists("quick_load_last_mod_cache"))
{
    quick_load_requested = global.quick_load_last_mod_cache;
}

if (quick_load_requested)
{
    global.quick_load_last_mod_cache = false;

    show_debug_message("Loader received quick load request.");

    if (scr_load_last_mod_cache_into_globals())
    {
        global.loading_sprite_buttons = true;

        loader_state = "create_buttons";
        load_text = "Loading cached sprite folders...";
        load_progress = 0.80;

        create_index = 0;

        show_debug_message("Using cached mod. Skipping scan.");
        show_debug_message("Cached mod root:");
        show_debug_message(global.mod_root);
        show_debug_message("Cached sprite folder count:");
        show_debug_message(string(global.sprite_folder_count));

        exit;
    }
    else
    {
        load_error = "Could not load cached mod. Use Select Mod Folder first.";
        loader_state = "error";
        global.loading_sprite_buttons = false;

        show_debug_message(load_error);

        exit;
    }
}



// NORMAL FULL SCAN SETUP


global.sprite_folder_count = 0;
global.sprite_folders = [];

if (!variable_global_exists("mod_root"))
{
    loader_state = "error";
    load_error = "ERROR: global.mod_root does not exist.";
    global.loading_sprite_buttons = false;
    exit;
}

mod_root = scr_normalize_folder_path(global.mod_root);

loader_state = "find_sprite_root";
load_text = "Starting full mod scan...";
load_progress = 0;