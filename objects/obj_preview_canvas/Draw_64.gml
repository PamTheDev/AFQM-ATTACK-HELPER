if (!variable_global_exists("timeline"))
{
    exit;
}

if (!variable_global_exists("current_timeline_frame"))
{
    global.current_timeline_frame = 0;
}



// Create / recreate clipped preview surface


if (!surface_exists(preview_surface))
{
    preview_surface = surface_create(canvas_w, canvas_h);
}

if (surface_exists(preview_surface))
{
    if (surface_get_width(preview_surface) != canvas_w || surface_get_height(preview_surface) != canvas_h)
    {
        surface_free(preview_surface);
        preview_surface = surface_create(canvas_w, canvas_h);
    }
}



// Get current animation frame and active hitboxes


var anim_frame = scr_get_active_animation_frame(
    global.timeline,
    global.current_timeline_frame
);

var active_hitboxes = scr_get_active_hitboxes(
    global.timeline,
    global.current_timeline_frame
);



// Draw preview contents to surface.
// Everything drawn here is clipped to canvas_w / canvas_h.


surface_set_target(preview_surface);

draw_clear_alpha(c_black, 0);



// Local canvas positions

// Because this is inside the surface, canvas_x/canvas_y are treated as 0,0.

var origin_screen_x = (preview_origin_x - canvas_x) + canvas_pan_x;
var origin_screen_y = (preview_origin_y - canvas_y) + canvas_pan_y;



// Draw canvas background


draw_set_alpha(1);

draw_set_color(make_color_rgb(25, 25, 25));
draw_rectangle(0, 0, canvas_w, canvas_h, false);

draw_set_color(make_color_rgb(60, 60, 60));
draw_rectangle(0, 0, canvas_w, canvas_h, true);



// Origin guide lines


draw_set_color(make_color_rgb(70, 70, 70));
draw_line(0, origin_screen_y, canvas_w, origin_screen_y);
draw_line(origin_screen_x, 0, origin_screen_x, canvas_h);



// Draw animation frame


if (variable_global_exists("loaded_frame_sprites"))
{
    if (anim_frame >= 0 && anim_frame < array_length(global.loaded_frame_sprites))
    {
        var spr = global.loaded_frame_sprites[anim_frame];

        if (spr != -1)
        {
            // This will draw from the middle center because
            // sprite_set_offset was used when loading the frame.
            draw_sprite_ext(
                spr,
                0,
                origin_screen_x,
                origin_screen_y,
                canvas_zoom,
                canvas_zoom,
                0,
                c_white,
                1
            );
        }
    }
}



// Draw active hitboxes as circle sprites


for (var i = 0; i < array_length(active_hitboxes); i++)
{
    var hb = active_hitboxes[i];

    var is_selected = false;

    if (!is_undefined(selected_hitbox))
    {
        is_selected = selected_hitbox == hb || hb == global.selected_hitbox;
    }

    var hitbox_color = scr_get_hitbox_color(hb);

    if (is_selected)
    {
        hitbox_color = merge_colour(hitbox_color, c_white, 0.4);
    }

    var hb_cx = origin_screen_x + hb.x * canvas_zoom;
    var hb_cy = origin_screen_y + hb.y * canvas_zoom;

    var hb_w = max(4, hb.xScale * hitbox_pixel_scale * canvas_zoom);
    var hb_h = max(4, hb.yScale * hitbox_pixel_scale * canvas_zoom);

    var draw_xscale = hb_w / hitbox_sprite_base_size;
    var draw_yscale = hb_h / hitbox_sprite_base_size;

    draw_sprite_ext(
        spr_hitbox_circle,
        0,
        hb_cx,
        hb_cy,
        draw_xscale,
        draw_yscale,
        0,
        hitbox_color,
        0.5
    );
if (variable_struct_exists(hb, "angle"))
{
    var hb_angle = real(hb.angle);

    var arrow_len = max(hb_w, hb_h) * 0.6;

    var hb_edgex = hb_cx + dcos(hb_angle) * arrow_len;
    var hb_edgey = hb_cy - dsin(hb_angle) * arrow_len;

    draw_set_color(c_white);
	if is_selected
		draw_set_alpha(0.3)
	else
		draw_set_alpha(0.7)
    draw_arrow(hb_cx, hb_cy, hb_edgex, hb_edgey, 15);
}

    // Optional outline box for selected hitbox only
    if (is_selected)
    {
        var hb_x1 = hb_cx - hb_w * 0.5;
        var hb_y1 = hb_cy - hb_h * 0.5;
        var hb_x2 = hb_cx + hb_w * 0.5;
        var hb_y2 = hb_cy + hb_h * 0.5;

        draw_set_color(c_white);
        draw_rectangle(hb_x1, hb_y1, hb_x2, hb_y2, true);

        // Resize handle
        draw_rectangle(
            hb_x2 - resize_handle_size,
            hb_y2 - resize_handle_size,
            hb_x2,
            hb_y2,
            false
        );
    }

    var hb_text = scr_get_hitbox_text(hb);

    draw_set_color(c_white);
    draw_text(
        hb_cx - (hb_w / 2),
        hb_cy + (hb_h / 2) - 16,
        hb_text + string(hb.id)
    );
}

//Draw Hitbox Preview

if (global.hitbox_creation_state != "" && start_new_hb_draw) {    
	
	var hitbox_function = scr_get_hitbox_create_function_from_type(global.hitbox_creation_type);

    var preview_hb = {
        hitboxCreateFunction: hitbox_function
    };

	var hitbox_color = scr_get_hitbox_color(preview_hb);
        hitbox_color = merge_colour(hitbox_color, c_white, 0.4);

    var hb_cx = origin_screen_x + new_hb_x * canvas_zoom;
    var hb_cy = origin_screen_y + new_hb_y * canvas_zoom;

    var hb_w = max(4, new_hb_xScale * hitbox_pixel_scale * canvas_zoom);
    var hb_h = max(4, new_hb_yScale * hitbox_pixel_scale * canvas_zoom);

    var draw_xscale = hb_w / hitbox_sprite_base_size;
    var draw_yscale = hb_h / hitbox_sprite_base_size;

    draw_sprite_ext(
        spr_hitbox_circle,
        0,
        hb_cx,
        hb_cy,
        draw_xscale,
        draw_yscale,
        0,
        hitbox_color,
        0.5
    );
	
}
// Finish drawing to clipped surface


surface_reset_target();



// Draw clipped preview surface to GUI


draw_set_alpha(1);
draw_surface(preview_surface, canvas_x, canvas_y);



// Draw canvas border on top


draw_set_color(make_color_rgb(60, 60, 60));
draw_rectangle(canvas_x, canvas_y, canvas_x + canvas_w, canvas_y + canvas_h, true);



// Info text outside the clipped canvas
window_set_caption("Editing Attack: " + string(global.selected_sprite_folder_name))

draw_set_color(c_white);
draw_text(canvas_x, canvas_y - 48, global.selected_sprite_folder_name);
draw_text(canvas_x, canvas_y - 28, "Timeline Frame: " + string(global.current_timeline_frame));
draw_text(canvas_x + 180, canvas_y - 28, "Animation Frame: " + string(anim_frame));
draw_text(canvas_x + 380, canvas_y - 28, "Hitboxes: " + string(array_length(active_hitboxes)));