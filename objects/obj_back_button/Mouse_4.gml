if (variable_global_exists("phase_check_window_open") && global.phase_check_window_open) exit;

// Finish any active editor input before releasing its target data.
scr_clear_text_input_focus();

// Most edits autosave immediately, but flush any remaining dirty state before
// unloading the attack.
if (variable_global_exists("attack_json_dirty") && global.attack_json_dirty)
{
    scr_save_current_attack_json();
}

// Clear references into the current timeline so the next attack opens with a
// clean editor state.
scr_clear_hitbox_selection();
scr_clear_animation_selection();
scr_clear_flag_selection();

global.selected_phase_index = -1;
global.current_timeline_frame = 0;
global.undo_history = [];
global.menu_focus = "default";

global.timeline = undefined;
global.current_attack_data = undefined;
global.current_attack_json_path = "";
global.attack_json_dirty = false;

global.pending_sprite_folder_name = "";
global.pending_sprite_folder_path = "";
global.pending_gml_path = "";
global.pending_json_path = "";
global.parser_waiting = false;
global.parser_process = undefined;

global.selected_sprite_folder_name = "";
global.selected_sprite_folder_path = undefined;
global.selected_gml_path = "";
global.selected_attack_gml_path = "";

global.hitbox_creation_state = "";
global.hitbox_creation_type = undefined;
global.current_flag_add = "";

window_set_caption("AFQM ATTACK HELPER");

// obj_preview_canvas releases the dynamically loaded frame sprites during the room transition
global.quick_load_last_mod_cache = true;
global.use_cached_sprite_folders = false;

room_goto(rm_spr_folders);
