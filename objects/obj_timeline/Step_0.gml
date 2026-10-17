if (variable_global_exists("phase_check_window_open") && global.phase_check_window_open)
{
    exit;
}

if (is_undefined(timeline))
{
    if (variable_global_exists("timeline"))
    {
        timeline = global.timeline;
        show_debug_message("obj_timeline connected to global.timeline.");
    }
    else
    {
        exit;
    }
}

if (is_undefined(timeline))
{
    exit;
}

if (!variable_global_exists("current_timeline_frame"))
{
    global.current_timeline_frame = 0;
}

if (global.current_timeline_frame < 0)
{
    global.current_timeline_frame = 0;
}

scr_timeline_ensure_phases(timeline);



// SHARED MOUSE / LAYOUT VALUES


var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var phase_area_h = phase_label_height + phase_bracket_height + phase_tag_gap + 4;

var content_x = timeline_x + header_w;
var content_w = timeline_w - header_w;

var phase_area_x1 = content_x;
var phase_area_y1 = timeline_y;
var phase_area_x2 = content_x + content_w;
var phase_area_y2 = timeline_y + phase_area_h;

var track_start_y = timeline_y + phase_area_h + ruler_h;

var mouse_over_timeline_header =
    mx >= timeline_x &&
    mx <= timeline_x + timeline_w &&
    my >= track_start_y - track_h &&
    my <= track_start_y;

var mouse_over_timeline =
    mx >= timeline_x &&
    mx <= timeline_x + timeline_w &&
    my >= timeline_y &&
    my <= timeline_y + timeline_h;

var mouse_in_phase_area = point_in_rectangle(
    mx,
    my,
    phase_area_x1,
    phase_area_y1,
    phase_area_x2,
    phase_area_y2
);



// Right-click targets use the same geometry as the timeline.
if (mouse_over_timeline && mouse_check_button_pressed(mb_right))
{
    scr_clear_text_input_focus();
    if (mouse_in_phase_area)
    {
        var frame = floor((mx - content_x + scroll_x) / frame_w);
        global.selected_phase_index = scr_timeline_get_phase_index_at_frame(timeline, frame);
        scr_show_only_text_input_group("phase");
        scr_context_menu_open("phase", id);
        var phase = timeline.phases[global.selected_phase_index];
        global.context_items[1].label = (variable_struct_exists(phase, "extend") && phase.extend ? "[x] " : "[ ] ") + "Extend phase";
    }
    else
    {
        context_track = floor((my - track_start_y + scroll_y) / track_h);
        context_key = undefined;
        if (context_track >= 0 && context_track < array_length(timeline.tracks))
        {
            var track = timeline.tracks[context_track];
            var frame = (mx - content_x + scroll_x) / frame_w;
            if (mx >= content_x)
                for (var k = 0; k < array_length(track.keys); k++)
                    if (frame >= track.keys[k].start && frame < track.keys[k].start + track.keys[k].duration)
                    { context_key = track.keys[k]; selected_track = context_track; selected_key = k; break; }
            if (!is_undefined(context_key) && (track.type == "flag" || track.type == "hitbox"))
            {
                var types = [];
                if (track.type == "flag")
                {
                    scr_select_flag_key_by_reference(timeline, context_key);
                    scr_show_only_text_input_group("flag");
                    var definitions = scr_get_flag_type_definitions();
                    for (var i = 0; i < array_length(definitions); i++)
                        array_push(types, scr_context_menu_input(definitions[i].label, 1, scr_context_type_action(context_key.flag, definitions[i].key, true)));
                }
                else
                {
                    scr_select_hitbox_key(timeline, context_track, selected_key);
                    scr_show_only_text_input_group("hitbox");
                    var functions = scr_get_hitbox_function_list();
                    for (var i = 0; i < array_length(functions); i++)
                        array_push(types, scr_context_menu_input(functions[i], 1, scr_context_type_action(context_key.hitbox, functions[i], false)));
                }
                var entry = scr_context_menu_input("Change type >", 1, function() {});
                entry.children = types;
                scr_context_menu_set_definition({ key: "key_type", inputs: [entry] });
                scr_context_menu_open("key_type", id);
            }
            else scr_context_menu_open("layer", id);
        }
        else scr_context_menu_open("layer", id);
    }
    exit;
}
if (global.context_active || global.context_click_consumed) exit;

// PHASE KEYBOARD SHORTCUTS
// N = add new phase after selected phase
// M = merge selected phase with next phase


if (global.selected_phase_index >= 0)
{
    if (keyboard_check_pressed(ord("N")))
    {
        scr_context_edit(method(id, function()
        {
            global.selected_phase_index = scr_timeline_add_phase_after(
                global.timeline,
                global.selected_phase_index,
                new_phase_default_duration
            );
            scr_refresh_text_input_group("phase");
        }));

exit;
    }

    if (keyboard_check_pressed(ord("M")))
    {
scr_timeline_merge_phase_with_next(global.timeline, global.selected_phase_index);

global.selected_phase_index = clamp(
    global.selected_phase_index,
    0,
    max(0, array_length(global.timeline.phases) - 1)
);

scr_sync_json_phase_lasts_from_timeline(global.timeline);
scr_save_current_attack_json();

exit;
    }
}



// PHASE EDGE DRAGGING


if (phase_drag_mode != "none")
{
    if (mouse_check_button(mb_left))
    {
        var mouse_frame = round((mx - content_x + scroll_x) / frame_w);
        mouse_frame = max(0, mouse_frame);

        if (phase_drag_mode == "right")
        {
            var phase_r = timeline.phases[phase_drag_index];
            var new_duration = mouse_frame - phase_r.start;

            scr_timeline_resize_phase_right(
                timeline,
                phase_drag_index,
                new_duration
            );
        }
        else if (phase_drag_mode == "left")
        {
            scr_timeline_resize_phase_left(
                timeline,
                phase_drag_index,
                mouse_frame
            );
        }

        exit;
    }
    else
{
    phase_drag_mode = "none";
    phase_drag_index = -1;

    scr_sort_all_timeline_tracks(global.timeline);
    scr_recalculate_timeline_total_frames(global.timeline);

    scr_sync_json_phase_lasts_from_timeline(global.timeline);
    scr_save_current_attack_json();

    exit;
}
}



// PHASE SELECT / RESIZE START


if (mouse_in_phase_area && mouse_check_button_pressed(mb_left))
{
    // Commit any code edit for the previously selected phase before changing
    // which phase owns the phase-panel code box.
    scr_clear_text_input_focus();

    global.selected_phase_index = -1;

    phase_drag_mode = "none";
    phase_drag_index = -1;

    for (var p = 0; p < array_length(timeline.phases); p++)
    {
        var phase = timeline.phases[p];

        var px1 = content_x + phase.start * frame_w - scroll_x;
        var px2 = content_x + (phase.start + phase.duration) * frame_w - scroll_x;

        var over_left = abs(mx - px1) <= phase_resize_handle_w;
        var over_right = abs(mx - px2) <= phase_resize_handle_w;
        var inside_phase = mx >= px1 && mx <= px2;

        if (over_left && p > 0)
        {
            global.selected_phase_index = p;
            phase_drag_index = p;
            phase_drag_mode = "left";

            show_debug_message("Phase left resize started.");
            break;
        }
        else if (over_right)
        {
            global.selected_phase_index = p;
            phase_drag_index = p;
            phase_drag_mode = "right";

            show_debug_message("Phase right resize started.");
            break;
        }
        else if (inside_phase)
        {
            global.selected_phase_index = p;
            show_debug_message("Selected phase:");
            show_debug_message(timeline.phases[p].name);
            break;
        }
    }

    if (global.selected_phase_index >= 0)
    {
        scr_show_only_text_input_group("phase");
        scr_refresh_text_input_group("phase");
    }

    exit;
}




// SCROLL / ZOOM


if (mouse_over_timeline)
{
    if (mouse_wheel_up() || mouse_wheel_down())
    {
        if (keyboard_check(vk_shift))
        {
            if (mouse_wheel_up())
            {
                scroll_x -= timeline_scroll_step * frame_w / frame_base_w;
            }

            if (mouse_wheel_down())
            {
                scroll_x += timeline_scroll_step * frame_w / frame_base_w;
            }
        }
        else if (keyboard_check(vk_control))
        {
            if (mouse_wheel_up())
            {
                frame_w += timeline_w_step;
            }

            if (mouse_wheel_down())
            {
                frame_w -= timeline_w_step;
            }
        }

        frame_w = clamp(frame_w, timeline_w_min, timeline_w_max);
        scroll_x = clamp(scroll_x, 0, 100000);
    }
}



// LEFT PRESS: SELECT KEY / RESIZE KEY / MOVE KEY / PLAYHEAD / ADD TRACK


if (mouse_over_timeline && mouse_check_button_pressed(mb_left))
{
    selected_track = -1;
	global.selected_phase_index = -1;
    selected_key = -1;
    drag_mode = "";

    var found_key = false;

    // Search keys from bottom to top.
    for (var t = array_length(timeline.tracks) - 1; t >= 0; t--)
    {
        var track = timeline.tracks[t];

        var row_y = track_start_y + t * track_h - scroll_y;

        if (my < row_y || my > row_y + track_h)
        {
            continue;
        }

        for (var k = array_length(track.keys) - 1; k >= 0; k--)
        {
            var key = track.keys[k];

            var key_x = content_x + key.start * frame_w - scroll_x;
            var key_w = max(6, key.duration * frame_w);

            if (track.type == "animation")
            {
                key_w = max(6, frame_w);
            }

            var key_y1 = row_y + 4;
            var key_y2 = row_y + track_h - 4;

            var inside_key =
                mx >= key_x &&
                mx <= key_x + key_w &&
                my >= key_y1 &&
                my <= key_y2;

			if (inside_key && !mouse_over_timeline_header)
			{
				selected_track = t;
				selected_key = k;

				if (track.type == "animation")
				{
					scr_clear_hitbox_selection();
					scr_clear_flag_selection();

					scr_toggle_select_animation_key(timeline, t, k);

					if (!is_undefined(global.selected_animation_key))
					{
						scr_show_only_text_input_group("frame");
					}
					else
					{
						scr_hide_all_text_input_groups();
					}
				}
				else if (track.type == "hitbox")
					{
					scr_clear_animation_selection();
					scr_clear_flag_selection();

					scr_select_hitbox_key(timeline, t, k);
					scr_show_only_text_input_group("hitbox");
				}
				else if (track.type == "flag")
				{
					scr_clear_animation_selection();
					scr_clear_hitbox_selection();

					scr_toggle_select_flag_key(timeline, t, k);

					if (!is_undefined(global.selected_flag_key))
					{
						scr_show_only_text_input_group("flag");
						scr_refresh_text_input_group("flag");
					}
					else
					{
						scr_hide_all_text_input_groups();
					}
				}
				else
				{
					scr_clear_animation_selection();
					scr_clear_hitbox_selection();
					scr_clear_flag_selection();
					scr_hide_all_text_input_groups();
				}

                drag_start_mouse_x = mx;
                drag_start_mouse_y = my;

                drag_start_key_start = key.start;
                drag_start_key_duration = key.duration;

                drag_start_track = t;
                drag_current_drop_track = t;

                global.current_timeline_frame = key.start;

                timeline_undo_active = true;
                timeline_undo_target_key = key;
                timeline_undo_before_state = scr_make_timeline_key_state(key);
                timeline_undo_before_track = t;
                timeline_undo_after_track = t;
                timeline_undo_track_type = track.type;
                timeline_undo_track_name = track.name;

                var inside_resize_handle = mx >= key_x + key_w - resize_handle_w;

                if (inside_resize_handle && track.type != "animation" && track.type != "flag")
                {
                    drag_mode = "resize";
                    show_debug_message("Timeline key resize started.");
                }
                else
                {
                    drag_mode = "move";
                    show_debug_message("Timeline key move started.");
                }

                found_key = true;
                break;
            }
        }

        if (found_key)
        {
            break;
        }
    }

    if (!found_key)
    {
        var new_track_row_y = track_start_y + array_length(timeline.tracks) * track_h - scroll_y;
		scr_clear_flag_selection();
		scr_clear_hitbox_selection();
		scr_clear_animation_selection();
		scr_hide_all_text_input_groups();

        var mouse_over_new_track_button =
            mx >= timeline_x &&
            mx <= timeline_x + header_w &&
            my >= new_track_row_y &&
            my <= new_track_row_y + track_h;

        if (mouse_over_new_track_button)
        {
            var new_track = {
                name: "Track " + string(array_length(timeline.tracks)),
                type: "hitbox",
                keys: []
            };

            array_push(timeline.tracks, new_track);

            global.redo_history = [];
        array_push(global.undo_history, {
                type: "track_added",
                target: array_length(timeline.tracks) - 1
            });

            show_debug_message("Added track " + string(array_length(timeline.tracks)));
            show_debug_message("Added track add undo action.");
            show_debug_message("Undo count: " + string(array_length(global.undo_history)));
        }
        else if (mx >= content_x && my >= phase_area_y2)
        {
            var clicked_frame = floor((mx - content_x + scroll_x) / frame_w);

            clicked_frame = clamp(
                clicked_frame,
                0,
                max(0, timeline.total_frames - 1)
            );

            global.current_timeline_frame = clicked_frame;
			drag_start_mouse_x = mx;
            drag_start_mouse_y = my;
            show_debug_message("Moved playhead to frame: " + string(global.current_timeline_frame));
        }
    }
}



// LEFT HELD: MOVE / RESIZE SELECTED KEY / MOVE PLAYHEAD


if (mouse_check_button(mb_left))
{
	if (mouse_over_timeline_header && drag_mode = "")
	{
            var clicked_frame = floor((mx - content_x + scroll_x) / frame_w);

            clicked_frame = clamp(
                clicked_frame,
                0,
                max(0, timeline.total_frames - 1)
            );

            global.current_timeline_frame = clicked_frame;
			drag_start_mouse_x = mx;
            drag_start_mouse_y = my;
	}
    if (selected_track != -1 && selected_key != -1 && drag_mode != "")
    {
        var frame_delta = round((mx - drag_start_mouse_x) / frame_w);

        var active_track = timeline.tracks[selected_track];
        var active_key = active_track.keys[selected_key];

        if (drag_mode == "move")
        {
            var new_start = drag_start_key_start + frame_delta;
            new_start = max(0, new_start);

            active_key.start = new_start;

            if (active_track.type == "animation" || active_track.type == "flag")
            {
                active_key.duration = 1;
            }

            global.current_timeline_frame = active_key.start;

            drag_current_drop_track = selected_track;

            if (active_track.type == "hitbox")
            {
                var hover_track = floor((my - track_start_y + scroll_y) / track_h);

                if (hover_track >= 0 && hover_track < array_length(timeline.tracks))
                {
                    if (timeline.tracks[hover_track].type == "hitbox")
                    {
                        drag_current_drop_track = hover_track;
                    }
                }
            }

            if (active_key.start + active_key.duration > timeline.total_frames)
            {
                timeline.total_frames = active_key.start + active_key.duration;
            }
        }

        if (drag_mode == "resize")
        {
            var new_duration = drag_start_key_duration + frame_delta;
            new_duration = max(1, new_duration);

            active_key.duration = new_duration;

            if (active_key.start + active_key.duration > timeline.total_frames)
            {
                timeline.total_frames = active_key.start + active_key.duration;
            }

            global.current_timeline_frame = active_key.start;
        }
    }
}



// LEFT RELEASE: FINISH KEY DRAG


if (mouse_check_button_released(mb_left))
{
    if (drag_mode != "")
    {
        show_debug_message("Timeline drag finished.");

        var moved_to_new_track = false;

        if (drag_mode == "move")
        {
            if (selected_track != -1 && selected_key != -1)
            {
                var source_track = timeline.tracks[selected_track];

                if (source_track.type == "hitbox")
                {
                    if (drag_current_drop_track != -1)
                    {
                        if (drag_current_drop_track != selected_track)
                        {
                            var moving_key = timeline_undo_target_key;

                            moved_to_new_track = scr_move_timeline_key_to_track(
                                timeline,
                                moving_key,
                                selected_track,
                                drag_current_drop_track
                            );

                            if (moved_to_new_track)
                            {
                                timeline_undo_after_track = drag_current_drop_track;

                                show_debug_message(
                                    "Moved hitbox key from track " +
                                    string(selected_track) +
                                    " to track " +
                                    string(drag_current_drop_track)
                                );
                            }
                        }
                    }
                }
            }
        }

        if (timeline_undo_active && !is_undefined(timeline_undo_target_key))
        {
            var after_state = scr_make_timeline_key_state(timeline_undo_target_key);

            timeline_undo_after_track = drag_current_drop_track;

            var timing_changed = !scr_timeline_key_states_equal(
                timeline_undo_before_state,
                after_state
            );

            var track_changed = timeline_undo_before_track != timeline_undo_after_track;

            if (timing_changed || track_changed)
            {
                global.redo_history = [];
        array_push(global.undo_history, {
                    type: "timeline_key_edit",
                    target: timeline_undo_target_key,
                    before: timeline_undo_before_state,
                    after: after_state,
                    from_track: timeline_undo_before_track,
                    to_track: timeline_undo_after_track,
                    track_type: timeline_undo_track_type,
                    track_name: timeline_undo_track_name
                });

                show_debug_message("Added timeline key edit undo action.");
                show_debug_message("Undo count: " + string(array_length(global.undo_history)));
            }
        }

        scr_sort_all_timeline_tracks(timeline);
        scr_recalculate_timeline_total_frames(timeline);
		mark_attack_json_dirty();
		scr_save_current_attack_json();
    }

    timeline_undo_active = false;
    timeline_undo_target_key = undefined;
    timeline_undo_before_state = undefined;
    timeline_undo_before_track = -1;
    timeline_undo_after_track = -1;
    timeline_undo_track_type = "";
    timeline_undo_track_name = "";

    drag_start_track = -1;
    drag_current_drop_track = -1;

    drag_mode = "";
    selected_track = -1;
    selected_key = -1;
}

if (global.selected_phase_index >= 0)
{
    scr_show_only_text_input_group("phase");
}
else if (!is_undefined(global.selected_flag_key))
{
    scr_show_only_text_input_group("flag");
}
else if (!is_undefined(global.selected_animation_key))
{
    scr_show_only_text_input_group("frame");
}
else if (!is_undefined(global.selected_hitbox))
{
    scr_show_only_text_input_group("hitbox");
}
else
{
    scr_hide_all_text_input_groups();
}
