// obj_generate_buttons Create Event

// Destroy old buttons
with (obj_sprite_folder_button)
{
    instance_destroy();
}

global.sprite_folder_count = 0;
global.sprite_folders = [];
global.loading_sprite_buttons = true;

gif_files = [];
gif_index = 0;
gif_conversion_started = false;
gif_wait_frames = 0;
gif_wait_max = room_speed * 30;

// Loader state
loader_state = "setup";
loader_progress = 0;
loader_text = "Starting...";
loader_error = "";
debug_message = "";

mod_root = "";
sprite_root = "";
search_mask = "";

found = "";
file_search_active = false;

found_sprite_folders = [];

scan_per_step = 40;
gml_checks_per_step = 1;
buttons_per_step = 8;

valid_index = 0;
create_index = 0;

done_timer = 30;

// Button layout
button_start_x = 64;
button_start_y = 56;
button_w = 230;
button_h = 40;
button_gap_x = 8;
button_gap_y = 8;
buttons_per_column = 14;



// Setup


if (!variable_global_exists("mod_root"))
{
    loader_state = "error";
    loader_error = "ERROR: global.mod_root does not exist.";
    global.loading_sprite_buttons = false;
    exit;
}

mod_root = scr_normalize_folder_path(global.mod_root);
sprite_root = scr_find_sprite_folder_root(mod_root);

if (sprite_root == "")
{
    loader_state = "error";
    loader_error = "ERROR: Could not find sprite folder root.";
    global.loading_sprite_buttons = false;
    exit;
}

show_debug_message("Scanning sprite folder root:");
show_debug_message(sprite_root);

sprite_root = scr_normalize_folder_path(sprite_root);

gif_files = scr_collect_sprite_gifs(sprite_root);
gif_index = 0;
gif_conversion_started = false;
gif_wait_frames = 0;
gif_wait_max = room_speed * 30;

show_debug_message("GIF files found:");
show_debug_message(string(array_length(gif_files)));

if (array_length(gif_files) > 0)
{
    loader_state = "convert_gifs";
    loader_text = "Converting GIFs...";
    loader_progress = 0.05;
}
else
{
    search_mask = sprite_root + "spr_*";

    show_debug_message("Sprite search mask:");
    show_debug_message(search_mask);

    found = file_find_first(search_mask, fa_directory);
    file_search_active = true;

    loader_state = "collect_folders";
    loader_text = "Scanning sprite folders...";
    loader_progress = 0.05;
}