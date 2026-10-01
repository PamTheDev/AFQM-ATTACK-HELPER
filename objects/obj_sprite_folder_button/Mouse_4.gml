if (variable_global_exists("new_attack_window_open") && global.new_attack_window_open) exit;

show_debug_message("Selected sprite folder:");
show_debug_message(sprite_folder_name);
show_debug_message(sprite_folder_path);

global.selected_sprite_folder_name = sprite_folder_name;
global.selected_sprite_folder_path = sprite_folder_path;
global.selected_attack_gml_path  = related_gml_path;
global.selected_attack_name = attack_name;

show_debug_message("Related GML path:");
show_debug_message(related_gml_path);

// Later this is where you will run the parser and open the editor room.
// Example:
// scr_open_sprite_attack(sprite_folder_name);
