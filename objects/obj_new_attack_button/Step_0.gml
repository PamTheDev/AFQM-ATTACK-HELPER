visible = !global.loading_sprite_buttons;

if (!window_open)
{
    exit;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

window_w = min(820, gui_w - 40);
window_h = min(560, gui_h - 40);
window_x = round((gui_w - window_w) * 0.5);
window_y = round((gui_h - window_h) * 0.5);

var content_x = window_x + 38;
var content_y = window_y + header_h + 42;
var left_w = window_w - preview_w - 114;

name_x = content_x;
name_y = content_y;
name_w = left_w;

folder_x = content_x;
folder_y = content_y + 104;
folder_w = max(120, left_w - browse_w - 12);
browse_x = folder_x + folder_w + 12;
browse_y = folder_y;

preview_x = window_x + window_w - preview_w - 38;
preview_y = content_y;

cancel_x = window_x + window_w - 38 - create_w - 12 - cancel_w;
cancel_y = window_y + window_h - footer_h + 17;
create_x = window_x + window_w - 38 - create_w;
create_y = cancel_y;

if (name_focused)
{
    attack_name = string_copy(keyboard_string, 1, 64);
    keyboard_string = attack_name;
}

// delta_time is measured in microseconds. Advancing this way keeps the
// preview at 30 FPS even when the room or display frame rate changes.
var preview_frame_count = array_length(preview_sprites);

if (preview_frame_count > 1)
{
    sprite_f += (delta_time / 1000000) * 30;
    sprite_f = sprite_f mod preview_frame_count;
}
else
{
    sprite_f = 0;
}

if (keyboard_check_pressed(vk_escape))
{
    close_new_attack_window();
    exit;
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if (mouse_check_button_pressed(mb_left))
{
    if (point_in_rectangle(mx, my, name_x, name_y, name_x + name_w, name_y + name_h))
    {
        name_focused = true;
        keyboard_string = attack_name;
    }
    else if (point_in_rectangle(mx, my, browse_x, browse_y, browse_x + browse_w, browse_y + browse_h))
    {
        name_focused = false;
        var folder = get_directory("Select the sprite folder");

        if (folder != "")
        {
            load_new_attack_preview(folder);
        }
    }
    else if (point_in_rectangle(mx, my, cancel_x, cancel_y, cancel_x + cancel_w, cancel_y + cancel_h))
    {
        close_new_attack_window();
        exit;
    }
    else if (point_in_rectangle(mx, my, create_x, create_y, create_x + create_w, create_y + create_h))
    {
        name_focused = false;
        create_new_attack();
        exit;
    }
    else
    {
        name_focused = false;
    }
}

if (keyboard_check_pressed(vk_enter))
{
    name_focused = false;
    create_new_attack();
}
