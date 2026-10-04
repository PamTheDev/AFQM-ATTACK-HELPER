button_width = 200;
// This object owns its menu choice and actions; the menu only renders inputs.
scr_context_menu_set_definition({
    key: "sprite_folder",
    inputs: [
        scr_context_menu_input("Edit", 1, function()
        {
            global.selected_sprite_folder_name = sprite_folder_name;
            global.selected_sprite_folder_path = sprite_folder_path;
            global.selected_gml_path = related_gml_path;
            global.selected_attack_gml_path = related_gml_path;
            global.selected_attack_name = attack_name;
            with (obj_edit_button) event_user(0);
        }, function() { return instance_exists(obj_edit_button); })
    ]
});
button_height = 40;

sprite_folder_index = -1;
sprite_folder_name = "";
sprite_folder_path = "";
related_gml_path = "";
attack_name = "";

hovered = false;

double_click_timer = 0;
double_click_max = round(room_speed * 0.30);

my_sprite = -1;
sprite_loaded = false;

if (!variable_global_exists("selected_sprite_folder_path"))
{
    global.selected_sprite_folder_path = undefined;
}
