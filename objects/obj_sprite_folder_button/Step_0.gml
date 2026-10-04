if (variable_global_exists("new_attack_window_open") && global.new_attack_window_open)
{
    exit;
}

hovered =
    mouse_x >= x &&
    mouse_x <= x + button_width &&
    mouse_y >= y &&
    mouse_y <= y + button_height;
if (double_click_timer > 0)
{
    double_click_timer -= 1;
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var bw = button_width;
var bh = button_height;

var hovering = point_in_rectangle(
    mx,
    my,
    x,
    y,
    x + bw,
    y + bh
);

if (hovering && mouse_check_button_pressed(mb_right)) {
    scr_context_menu_open("sprite_folder", id);
}
if (hovering && mouse_check_button_pressed(mb_left) && !global.context_click_consumed)
{
    // First click selects the folder.
    global.selected_sprite_folder_name = sprite_folder_name;
    global.selected_sprite_folder_path = sprite_folder_path;
    global.selected_gml_path = related_gml_path;
    global.selected_attack_gml_path = related_gml_path;
    global.selected_attack_name = attack_name;

    show_debug_message("Selected sprite folder:");
    show_debug_message(sprite_folder_name);

    // Second click edits.
    if (double_click_timer > 0)
    {
        double_click_timer = 0;

var edit_button = instance_find(obj_edit_button, 0);

if (edit_button != noone)
{
    with (edit_button)
    {
        event_user(0);
    }
}
else
{
    show_message("Edit button was not found.");
}
    }
    else
    {
        double_click_timer = double_click_max;
    }
}
/* if (!sprite_loaded && sprite_folder_path != "" && sprite_folder_name != "")
{
    var full_path = sprite_folder_path + sprite_folder_name + "_0.png";

    full_path = string_replace_all(full_path, "\\", "/");

    show_debug_message("Trying to load sprite preview:");
    show_debug_message(full_path);

    if (file_exists(full_path))
    {
        my_sprite = sprite_add(full_path, 1, false, false, 0, 0);

        if (my_sprite != -1)
        {
            sprite_loaded = true;
            show_debug_message("Loaded sprite preview successfully.");
        }
        else
        {
            sprite_loaded = true;
            show_debug_message("ERROR: sprite_add failed.");
        }
    }
    else
    {
        sprite_loaded = true;
        show_debug_message("ERROR: Preview image does not exist:");
        show_debug_message(full_path);
    }
}
