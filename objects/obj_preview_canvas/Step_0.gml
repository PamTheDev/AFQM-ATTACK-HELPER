if (!variable_global_exists("timeline"))
{
    exit;
}

if (!variable_global_exists("current_timeline_frame"))
{
    global.current_timeline_frame = 0;
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var mouse_over_canvas =
    mx >= canvas_x &&
    mx <= canvas_x + canvas_w &&
    my >= canvas_y &&
    my <= canvas_y + canvas_h;
// Sync local preview selection from global selection every frame.
// This makes timeline key selection immediately select/highlight the preview hitbox.
if (variable_global_exists("selected_hitbox"))
{
    selected_hitbox = global.selected_hitbox;
}
else
{
    selected_hitbox = undefined;
}

selected_hitbox_index = -1;

if (!is_undefined(selected_hitbox))
{
    var sync_active_hitboxes = scr_get_active_hitboxes(
        global.timeline,
        global.current_timeline_frame
    );

    for (var sync_i = 0; sync_i < array_length(sync_active_hitboxes); sync_i++)
    {
        if (sync_active_hitboxes[sync_i] == selected_hitbox)
        {
            selected_hitbox_index = sync_i;
            break;
        }
    }
}
if (mouse_over_canvas)
{
    if (mouse_wheel_up() || mouse_wheel_down())
    {
        // Find which world point the mouse is currently over
        var origin_screen_x = preview_origin_x + canvas_pan_x;
        var origin_screen_y = preview_origin_y + canvas_pan_y;

        var world_mouse_x = (mx - origin_screen_x) / canvas_zoom;
        var world_mouse_y = (my - origin_screen_y) / canvas_zoom;

        // Change zoom
        if (mouse_wheel_up())
        {
            canvas_zoom *= canvas_zoom_step;
        }

        if (mouse_wheel_down())
        {
            canvas_zoom /= canvas_zoom_step;
        }

        canvas_zoom = clamp(canvas_zoom, canvas_zoom_min, canvas_zoom_max);

        // Reposition pan so zoom happens toward the mouse cursor
        canvas_pan_x = mx - preview_origin_x - world_mouse_x * canvas_zoom;
        canvas_pan_y = my - preview_origin_y - world_mouse_y * canvas_zoom;
    }
}


if (mouse_over_canvas && mouse_check_button_pressed(mb_middle))
{
    panning_canvas = true;

    pan_start_mouse_x = mx;
    pan_start_mouse_y = my;

    pan_start_x = canvas_pan_x;
    pan_start_y = canvas_pan_y;
}

if (panning_canvas)
{
    if (mouse_check_button(mb_middle))
    {
        canvas_pan_x = pan_start_x + (mx - pan_start_mouse_x);
        canvas_pan_y = pan_start_y + (my - pan_start_mouse_y);
    }
    else
    {
        panning_canvas = false;
    }
}

if (keyboard_check(vk_control) && keyboard_check_pressed(ord("Z")) && global.hitbox_creation_state == "")
{
    scr_undo_last_action();
}


// Mouse press: select hitbox or start dragging/resizing

if (mouse_over_canvas && mouse_check_button_pressed(mb_left) && global.hitbox_creation_state == "")
{
    selected_hitbox = undefined;
    selected_hitbox_index = -1;
    dragging_hitbox = false;
    resizing_hitbox = false;

    var active_hitboxes = scr_get_active_hitboxes(
        global.timeline,
        global.current_timeline_frame
    );

    for (var i = array_length(active_hitboxes) - 1; i >= 0; i--)
    {
        var hb = active_hitboxes[i];

        var origin_screen_x = preview_origin_x + canvas_pan_x;
        var origin_screen_y = preview_origin_y + canvas_pan_y;

        var hb_cx = origin_screen_x + hb.x * canvas_zoom;
        var hb_cy = origin_screen_y + hb.y * canvas_zoom;

        var hb_w = max(4, hb.xScale * hitbox_pixel_scale * canvas_zoom);
        var hb_h = max(4, hb.yScale * hitbox_pixel_scale * canvas_zoom);

        var hb_x1 = hb_cx - hb_w * 0.5;
        var hb_y1 = hb_cy - hb_h * 0.5;
        var hb_x2 = hb_cx + hb_w * 0.5;
        var hb_y2 = hb_cy + hb_h * 0.5;

        var handle_x1 = hb_x2 - resize_handle_size;
        var handle_y1 = hb_y2 - resize_handle_size;
        var handle_x2 = hb_x2;
        var handle_y2 = hb_y2;

        var inside_hitbox =
            mx >= hb_x1 &&
            mx <= hb_x2 &&
            my >= hb_y1 &&
            my <= hb_y2;

        var inside_resize_handle =
            mx >= handle_x1 &&
            mx <= handle_x2 &&
            my >= handle_y1 &&
            my <= handle_y2;

        if (inside_hitbox)
        {
            selected_hitbox = hb;
            selected_hitbox_index = i;

            if (variable_global_exists("timeline"))
            {
                scr_select_hitbox_from_hitbox(global.timeline, hb);
            }
            else
            {
                global.selected_hitbox = hb;
            }

            undo_active = true;
            undo_target_hitbox = hb;
            undo_before_state = scr_make_hitbox_state(hb);

            drag_start_mouse_x = mx;
            drag_start_mouse_y = my;

            drag_start_hb_x = hb.x;
            drag_start_hb_y = hb.y;
            drag_start_hb_xscale = hb.xScale;
            drag_start_hb_yscale = hb.yScale;

            if (inside_resize_handle)
            {
                resizing_hitbox = true;
            }
            else
            {
                dragging_hitbox = true;
            }

            break;
        }
    }

    if (is_undefined(selected_hitbox))
    {
        scr_clear_hitbox_selection();

        selected_hitbox = undefined;
        selected_hitbox_index = -1;
    }
}


// Mouse held: move or resize selected hitbox

if (mouse_check_button(mb_left) && global.hitbox_creation_state == "")
{
    if (!is_undefined(selected_hitbox) && (dragging_hitbox || resizing_hitbox))
    {
        var dx = mx - drag_start_mouse_x;
        var dy = my - drag_start_mouse_y;

        if (dragging_hitbox)
        {
            selected_hitbox.x = drag_start_hb_x + dx / canvas_zoom;
            selected_hitbox.y = drag_start_hb_y + dy / canvas_zoom;
        }

        if (resizing_hitbox)
        {
            selected_hitbox.xScale = max(0.05, drag_start_hb_xscale + dx / (hitbox_pixel_scale * canvas_zoom));
            selected_hitbox.yScale = max(0.05, drag_start_hb_yscale + dy / (hitbox_pixel_scale * canvas_zoom));
        }
    }
}
//if mouse released then check for undo
if (mouse_check_button_released(mb_left))
{
    if (undo_active && !is_undefined(undo_target_hitbox))
    {
        var after_state = scr_make_hitbox_state(undo_target_hitbox);

        if (!scr_hitbox_states_equal(undo_before_state, after_state))
        {
            array_push(global.undo_history, {
                type: "hitbox_transform",
                target: undo_target_hitbox,
                before: undo_before_state,
                after: after_state,
                frame: global.current_timeline_frame
            });

            show_debug_message("Added hitbox undo action.");
            show_debug_message("Undo count: " + string(array_length(global.undo_history)));
			
			mark_attack_json_dirty();
			scr_save_current_attack_json();
        }
    }

    undo_active = false;
    undo_target_hitbox = undefined;
    undo_before_state = undefined;

    dragging_hitbox = false;
    resizing_hitbox = false;
}

if  (global.hitbox_creation_state != "") {
	switch (global.hitbox_creation_state) {
		
		case "start":
			if (mouse_check_button_released(mb_left)) {
				new_hb_x = 0
                new_hb_y = 0
				start_new_hb_draw = false;

                new_hb_xScale = 0;
                new_hb_yScale = 0;
				global.hitbox_creation_state = "position";
				show_debug_message("Hitbox button " + string(global.hitbox_creation_type) + " pressed");
			};
			break;
		
        case "position":
        {
            if (mouse_over_canvas && mouse_check_button_pressed(mb_left))
            {
				start_new_hb_draw = true;
                var origin_screen_x = preview_origin_x + canvas_pan_x;
                var origin_screen_y = preview_origin_y + canvas_pan_y;

                new_hb_x = (mx - origin_screen_x) / canvas_zoom;
                new_hb_y = (my - origin_screen_y) / canvas_zoom;

                new_hb_start_mouse_x = mx;
                new_hb_start_mouse_y = my;

                new_hb_xScale = 0.5;
                new_hb_yScale = 0.5;

                global.hitbox_creation_state = "scale";

                show_debug_message("Created hitbox preview at " + string(new_hb_x) + ", " + string(new_hb_y));
            }

            break;
        }
		case "scale":
        {
            if (mouse_check_button(mb_left))
            {
                var dx = mx - new_hb_start_mouse_x;
                var dy = my - new_hb_start_mouse_y;

                new_hb_xScale = max(0.05, abs(dx) / (hitbox_pixel_scale * canvas_zoom));
                new_hb_yScale = max(0.05, abs(dy) / (hitbox_pixel_scale * canvas_zoom));
            }

            if (mouse_check_button_released(mb_left))
            {
                global.hitbox_creation_state = "create";

                show_debug_message("Scaled hitbox preview to " + string(new_hb_xScale) + ", " + string(new_hb_yScale));
            }

            break;
        }
		case "create":
        {
			scr_add_hitbox_at_playhead(global.timeline, new_hb_x, new_hb_y, new_hb_xScale, new_hb_yScale, scr_get_hitbox_create_function_from_type(global.hitbox_creation_type));
            global.hitbox_creation_state = "";
				start_new_hb_draw = false;
            // show_debug_message("Scaled hitbox preview to " + string(new_hb_xScale) + ", " + string(new_hb_yScale));

            break;
        }
	}
	
	exit;
}