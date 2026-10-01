if (
    window_open ||
    global.loading_sprite_buttons ||
    (variable_global_exists("new_attack_window_open") && global.new_attack_window_open)
)
{
    exit;
}

for (var old_preview = 0; old_preview < array_length(preview_sprites); old_preview++)
{
    if (sprite_exists(preview_sprites[old_preview]))
    {
        sprite_delete(preview_sprites[old_preview]);
    }
}

preview_sprites = [];
preview_sprite = -1;
sprite_f = 0;

window_open = true;
name_focused = true;
attack_name = "";
selected_folder_path = "";
selected_folder_name = "";
status_text = "";
status_is_error = false;
global.new_attack_window_open = true;
keyboard_string = attack_name;
