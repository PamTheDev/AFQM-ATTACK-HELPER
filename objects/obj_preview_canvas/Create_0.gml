
// Preview canvas position/size


canvas_x = ref_preview_canvas.x;
canvas_y = ref_preview_canvas.y;
canvas_w = 750;
canvas_h = 400;

// Character origin in the preview canvas
preview_origin_x = canvas_x + canvas_w * 0.5;
preview_origin_y = canvas_y + canvas_h * 0.6;

// This is the visual pixel size multiplier for hitboxes.
// If hb.xScale = 0.8, the visual width becomes 80 pixels.
hitbox_pixel_scale = 65;

// Your hitbox sprite is 64x64.
// The code will convert desired pixel size into draw_sprite_ext scale.
hitbox_sprite_base_size = 64;


// Interaction state


selected_hitbox = undefined;
selected_hitbox_index = -1;

dragging_hitbox = false;
resizing_hitbox = false;

drag_start_mouse_x = 0;
drag_start_mouse_y = 0;

drag_start_hb_x = 0;
drag_start_hb_y = 0;
drag_start_hb_xscale = 0;
drag_start_hb_yscale = 0;

resize_handle_size = 10;

undo_active = false;
undo_target_hitbox = undefined;
undo_before_state = undefined;

if (!variable_global_exists("undo_history"))
{
    global.undo_history = [];
}
if (!variable_global_exists("current_timeline_frame"))
{
    global.current_timeline_frame = 0;
}

if (!variable_global_exists("loaded_frame_sprites"))
{
    global.loaded_frame_sprites = [];
}


// Preview zoom / pan


canvas_zoom = 2.25;
canvas_zoom_min = 0.25;
canvas_zoom_max = 4;
canvas_zoom_step = 1.15;

canvas_pan_x = 0;
canvas_pan_y = 0;

preview_surface = -1;

panning_canvas = false;
pan_start_mouse_x = 0;
pan_start_mouse_y = 0;
pan_start_x = 0;
pan_start_y = 0;

new_hb_x = 0;
new_hb_y = 0;
new_hb_xScale = 0;
new_hb_yScale = 0;
start_new_hb_draw = false;