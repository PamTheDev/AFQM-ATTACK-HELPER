button_width = 200;
button_height = 40;

sprite_folder_index = -1;
sprite_folder_name = "";
sprite_folder_path = "";
related_gml_path = "";

hovered = false;

double_click_timer = 0;
double_click_max = round(room_speed * 0.30);

my_sprite = -1;
sprite_loaded = false;

if (!variable_global_exists("selected_sprite_folder_path"))
{
    global.selected_sprite_folder_path = undefined;
}