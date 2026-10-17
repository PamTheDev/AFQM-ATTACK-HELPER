if (!window_open)
{
    exit;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Dim the room behind the modal.
draw_set_alpha(0.72);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

// Window, header, and footer.
draw_set_color(make_color_rgb(24, 25, 30));
draw_roundrect(window_x, window_y, window_x + window_w, window_y + window_h, false);
draw_set_color(make_color_rgb(54, 57, 68));
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);
draw_set_color(make_color_rgb(31, 33, 39));
draw_rectangle(window_x, window_y + window_h - footer_h, window_x + window_w, window_y + window_h, false);
draw_set_color(make_color_rgb(105, 110, 126));
draw_roundrect(window_x, window_y, window_x + window_w, window_y + window_h, true);

draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(window_x + 28, window_y + header_h * 0.5, "Create New Attack");

// Name field.
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(195, 198, 207));
draw_text(name_x, name_y - 8, "Attack name");

draw_set_color(make_color_rgb(14, 15, 19));
draw_roundrect(name_x, name_y, name_x + name_w, name_y + name_h, false);
draw_set_color(name_focused ? make_color_rgb(100, 166, 255) : make_color_rgb(80, 84, 96));
draw_roundrect(name_x, name_y, name_x + name_w, name_y + name_h, true);

draw_set_valign(fa_middle);
var shown_name = attack_name;

while (string_width(shown_name) > name_w - 28 && string_length(shown_name) > 0)
{
    shown_name = string_delete(shown_name, 1, 1);
}

draw_set_color(attack_name == "" ? make_color_rgb(115, 118, 128) : c_white);
draw_text(name_x + 13, name_y + name_h * 0.5, attack_name == "" ? "example_attack -- no spaces" : shown_name);

if (name_focused && ((current_time div 500) mod 2 == 0))
{
    var caret_x = name_x + 13 + string_width(shown_name) + 1;
    draw_set_color(c_white);
    draw_line(caret_x, name_y + 10, caret_x, name_y + name_h - 10);
}

// Sprite folder field and file-explorer button.
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(195, 198, 207));
draw_text(folder_x, folder_y - 8, "Sprite folder");

draw_set_color(make_color_rgb(14, 15, 19));
draw_roundrect(folder_x, folder_y, folder_x + folder_w, folder_y + folder_h, false);
draw_set_color(make_color_rgb(80, 84, 96));
draw_roundrect(folder_x, folder_y, folder_x + folder_w, folder_y + folder_h, true);

draw_set_valign(fa_middle);
draw_set_color(selected_folder_name == "" ? make_color_rgb(115, 118, 128) : c_white);
draw_text(folder_x + 13, folder_y + folder_h * 0.5, selected_folder_name == "" ? "No folder selected" : selected_folder_name);

var browse_hover = point_in_rectangle(mx, my, browse_x, browse_y, browse_x + browse_w, browse_y + browse_h);
draw_set_color(browse_hover ? make_color_rgb(84, 132, 193) : make_color_rgb(62, 99, 148));
draw_roundrect(browse_x, browse_y, browse_x + browse_w, browse_y + browse_h, false);
draw_set_color(make_color_rgb(125, 172, 231));
draw_roundrect(browse_x, browse_y, browse_x + browse_w, browse_y + browse_h, true);
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text(browse_x + browse_w * 0.5, browse_y + browse_h * 0.5, "Browse...");

// Preview is rendered into a surface so it stays clipped to its panel.
if (!surface_exists(preview_surface))
{
    preview_surface = surface_create(preview_w, preview_h);
}

if (surface_exists(preview_surface))
{
    surface_set_target(preview_surface);
    draw_clear_alpha(make_color_rgb(17, 18, 22), 1);

    draw_set_color(make_color_rgb(45, 47, 55));
    draw_line(preview_w * 0.5, 0, preview_w * 0.5, preview_h);
    draw_line(0, preview_h * 0.5, preview_w, preview_h * 0.5);

    var preview_frame_count = array_length(preview_sprites);

    if (preview_frame_count > 0)
    {
        var preview_frame_index = clamp(floor(sprite_f), 0, preview_frame_count - 1);
        preview_sprite = preview_sprites[preview_frame_index];

        var sw = max(1, sprite_get_width(preview_sprite));
        var sh = max(1, sprite_get_height(preview_sprite));
        var scale = min((preview_w - 30) / sw, (preview_h - 30) / sh);

        draw_sprite_ext(
            preview_sprite,
            0,
            preview_w * 0.5,
            preview_h * 0.5,
            scale,
            scale,
            0,
            c_white,
            1
        );
    }
    else
    {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(make_color_rgb(130, 133, 143));
        draw_text(preview_w * 0.5, preview_h * 0.5, "Sprite preview");
    }

    surface_reset_target();
    draw_set_alpha(1);
    draw_surface(preview_surface, preview_x, preview_y);
}

draw_set_color(make_color_rgb(80, 84, 96));
draw_rectangle(preview_x, preview_y, preview_x + preview_w, preview_y + preview_h, true);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(155, 158, 168));
draw_text_ext(
    folder_x,
    folder_y + folder_h + 28,
    "Creates an attack with 3 phases; Startup, Active, Recovery.",
    18,
    name_w
);

if (status_text != "")
{
    draw_set_color(status_is_error ? make_color_rgb(255, 112, 112) : make_color_rgb(126, 217, 153));
    draw_text_ext(folder_x, folder_y + folder_h + 66, status_text, 18, name_w);
}

// Footer buttons.
var cancel_hover = point_in_rectangle(mx, my, cancel_x, cancel_y, cancel_x + cancel_w, cancel_y + cancel_h);
draw_set_color(cancel_hover ? make_color_rgb(76, 79, 90) : make_color_rgb(55, 58, 67));
draw_roundrect(cancel_x, cancel_y, cancel_x + cancel_w, cancel_y + cancel_h, false);
draw_set_color(make_color_rgb(104, 108, 121));
draw_roundrect(cancel_x, cancel_y, cancel_x + cancel_w, cancel_y + cancel_h, true);

var can_create = attack_name != "" && selected_folder_path != "";
var create_hover = point_in_rectangle(mx, my, create_x, create_y, create_x + create_w, create_y + create_h);
draw_set_color(
    can_create
        ? (create_hover ? make_color_rgb(67, 151, 105) : make_color_rgb(49, 122, 82))
        : make_color_rgb(53, 61, 58)
);
draw_roundrect(create_x, create_y, create_x + create_w, create_y + create_h, false);
draw_set_color(can_create ? make_color_rgb(101, 198, 139) : make_color_rgb(78, 86, 82));
draw_roundrect(create_x, create_y, create_x + create_w, create_y + create_h, true);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(cancel_x + cancel_w * 0.5, cancel_y + cancel_h * 0.5, "Cancel");
draw_set_color(can_create ? c_white : make_color_rgb(135, 139, 137));
draw_text(create_x + create_w * 0.5, create_y + create_h * 0.5, "Create Attack");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
