timeline_x = ref_timeline.x;
timeline_y = ref_timeline.y;

header_w = 140;
track_h = 28;
frame_base_w = 30;
frame_w = 30;

timeline_w = 960;
timeline_h = 200;

scroll_x = 0;
scroll_y = 0;

timeline_w_min = 5;
timeline_w_max = 100;
timeline_w_step = 1.15;
timeline_scroll_step = 30;

timeline_surface = -1;

selected_track = -1;
selected_key = -1;

drag_mode = "";
drag_start_mouse_x = 0;
drag_start_key_start = 0;
drag_start_key_duration = 0;
drag_start_mouse_y = 0;
drag_start_track = -1;
drag_current_drop_track = -1;

timeline_undo_before_track = -1;
timeline_undo_after_track = -1;

resize_handle_w = 8;

timeline = undefined;

timeline_undo_active = false;
timeline_undo_target_key = undefined;
timeline_undo_before_state = undefined;
timeline_undo_track_type = "";
timeline_undo_track_name = "";

// Phase tag / bracket UI
phase_label_height = 14;
phase_bracket_height = 14; // Adjust this to make the bracket taller/shorter
phase_tag_gap = 4;

phase_resize_handle_w = 6;
phase_drag_mode = "none";
phase_drag_index = -1;

selected_phase_index = -1;

new_phase_default_duration = 5;

// Make sure this matches your timeline draw code
header_w = 120;
ruler_h = 24;


if (!variable_global_exists("current_timeline_frame")) global.current_timeline_frame = 0;
if (variable_global_exists("timeline")) timeline = global.timeline;
if (variable_global_exists("menu_focus")) global.menu_focus = "default";

if (!variable_global_exists("selected_hitbox")) global.selected_hitbox = undefined;
if (!variable_global_exists("selected_hitbox_key")) global.selected_hitbox_key = undefined;
if (!variable_global_exists("selected_hitbox_track")) global.selected_hitbox_track = -1;
if (!variable_global_exists("selected_hitbox_key_index")) global.selected_hitbox_key_index = -1;

if (!variable_global_exists("selected_animation_key")) global.selected_animation_key = undefined;
if (!variable_global_exists("selected_animation_track")) global.selected_animation_track = -1;
if (!variable_global_exists("selected_animation_key_index")) global.selected_animation_key_index = -1;