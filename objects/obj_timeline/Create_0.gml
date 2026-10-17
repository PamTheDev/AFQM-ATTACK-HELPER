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

if (!variable_global_exists("selected_phase_index")) global.selected_phase_index = -1;

new_phase_default_duration = 4;

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

if (!variable_global_exists("selected_flag_key")) global.selected_flag_key = undefined;
if (!variable_global_exists("selected_flag_track")) global.selected_flag_track = -1;
if (!variable_global_exists("selected_flag_key_index")) global.selected_flag_key_index = -1;
context_track = -1;
context_key = undefined;
scr_context_menu_set_definition({ key: "attack", inputs: [] });
scr_context_menu_set_definition({ key: "phase", inputs: [
    scr_context_menu_input("Delete Phase", 1, function()
    {
        scr_context_edit(method(id, function()
        {
            var p = global.selected_phase_index;
            var removed = timeline.phases[p];
            array_delete(timeline.phases, p, 1);
            for (var i = p; i < array_length(timeline.phases); i++) timeline.phases[i].start -= removed.duration;
            if (array_length(timeline.phases) > 0)
            {
                timeline.phases[0].extend = false;
                timeline.phases[array_length(timeline.phases) - 1].extend = false;
            }
            global.selected_phase_index = -1;
        }));
    }, function() { return global.selected_phase_index >= 0 && array_length(timeline.phases) > 1; }),
    scr_context_menu_input("Extend phase", 1, function()
    {
        scr_context_edit(method(id, function()
        {
            var phase = timeline.phases[global.selected_phase_index];
            phase.extend = !(variable_struct_exists(phase, "extend") && phase.extend);
        }));
    }, function() { return global.selected_phase_index > 0 && global.selected_phase_index < array_length(timeline.phases) - 1; }),
    scr_context_menu_input("Insert Phase", 1, function()
    {
        scr_context_edit(method(id, function()
        {
            global.selected_phase_index = scr_timeline_add_phase_after(timeline, global.selected_phase_index, new_phase_default_duration);
            scr_show_only_text_input_group("phase");
            scr_refresh_text_input_group("phase");
        }));
    }, function() { return global.selected_phase_index >= 0 && global.selected_phase_index < array_length(timeline.phases); })
] });
scr_context_menu_set_definition({ key: "layer", inputs: [
    scr_context_menu_input("New flag layer", 1, function()
    {
        scr_context_edit(method(id, function() { scr_create_flag_track(timeline); }));
    }),
    scr_context_menu_input("New Hitbox Layer", 1, function()
    {
        scr_context_edit(method(id, function()
        {
            array_push(timeline.tracks, { name: "Hitbox " + string(scr_count_hitbox_tracks(timeline) + 1), type: "hitbox", keys: [] });
        }));
    }),
    scr_context_menu_input("Delete layer", 2, function()
    {
        scr_context_edit(method(id, function()
        {
            array_delete(timeline.tracks, context_track, 1);
            scr_clear_hitbox_selection();
            scr_clear_animation_selection();
            global.selected_flag_key = undefined;
            global.selected_flag_track = -1;
            selected_track = -1;
            selected_key = -1;
            scr_renumber_flag_tracks(timeline);
            var number = 0;
            for (var t = 0; t < array_length(timeline.tracks); t++)
                if (timeline.tracks[t].type == "hitbox") timeline.tracks[t].name = "Hitbox " + string(++number);
            scr_show_only_text_input_group("default");
        }));
    }, function() { return context_track >= 0 && context_track < array_length(timeline.tracks) && timeline.tracks[context_track].type != "animation"; })
] });
