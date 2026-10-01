parser_check_attempts = 0;
parser_check_max_attempts = 300;

window_open = false;
name_focused = false;
attack_name = "";
selected_folder_path = "";
selected_folder_name = "";
preview_sprite = -1;
preview_sprites = [];
preview_surface = -1;
status_text = "";
status_is_error = false;

window_w = 820;
window_h = 560;
header_h = 64;
footer_h = 76;

window_x = 0;
window_y = 0;
name_x = 0;
name_y = 0;
name_w = 0;
name_h = 44;
folder_x = 0;
folder_y = 0;
folder_w = 0;
folder_h = 44;
browse_x = 0;
browse_y = 0;
browse_w = 130;
browse_h = 44;
preview_x = 0;
preview_y = 0;
preview_w = 270;
preview_h = 250;
cancel_x = 0;
cancel_y = 0;
cancel_w = 120;
cancel_h = 42;
create_x = 0;
create_y = 0;
create_w = 150;
create_h = 42;

sprite_f = 0;

if (!variable_global_exists("new_attack_window_open"))
{
    global.new_attack_window_open = false;
}

close_new_attack_window = function()
{
    window_open = false;
    name_focused = false;
    global.new_attack_window_open = false;
    keyboard_string = "";
};

load_new_attack_preview = function(_folder)
{
    _folder = scr_normalize_folder_path(_folder);

    if (!directory_exists(_folder))
    {
        status_text = "That sprite folder no longer exists.";
        status_is_error = true;
        return false;
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
    selected_folder_path = _folder;
    selected_folder_name = scr_get_path_folder_name(_folder);

    var preview_path = "";
    var filename_mode = "";
    var filename_index_offset = 0;

    if (file_exists(_folder + selected_folder_name + "_0.png"))
    {
        filename_mode = "named";
    }
    else if (file_exists(_folder + selected_folder_name + "_1.png"))
    {
        filename_mode = "named";
        filename_index_offset = 1;
    }
    else if (file_exists(_folder + generate_image_name(0) + ".png"))
    {
        filename_mode = "numeric";
    }
    else if (file_exists(_folder + generate_image_name(1) + ".png"))
    {
        filename_mode = "numeric";
        filename_index_offset = 1;
    }

    if (filename_mode != "")
    {
        var frame_index = 0;

        while (frame_index <= 500)
        {
            var file_index = frame_index + filename_index_offset;

            if (filename_mode == "named")
            {
                preview_path = _folder + selected_folder_name + "_" + string(file_index) + ".png";
            }
            else
            {
                preview_path = _folder + generate_image_name(file_index) + ".png";
            }

            if (!file_exists(preview_path))
            {
                break;
            }

            var frame_sprite = sprite_add(preview_path, 1, false, false, 0, 0);

            if (sprite_exists(frame_sprite))
            {
                sprite_set_offset(
                    frame_sprite,
                    sprite_get_width(frame_sprite) * 0.5,
                    sprite_get_height(frame_sprite) * 0.5
                );

                array_push(preview_sprites, frame_sprite);
            }

            frame_index += 1;
        }
    }

    // Still show a useful preview for a folder with an unusual naming scheme.
    // Creation remains stricter because the editor needs a numbered sequence.
    if (array_length(preview_sprites) == 0)
    {
        var found = file_find_first(_folder + "*.png", 0);

        if (found == "")
        {
            file_find_close();
            found = file_find_first(_folder + "*.PNG", 0);
        }

        if (found != "")
        {
            found = string_replace_all(found, "\\", "/");
            preview_path = found;

            if (string_pos("/", found) == 0)
            {
                preview_path = _folder + found;
            }
        }

        file_find_close();
    }

    if (array_length(preview_sprites) == 0 && preview_path == "")
    {
        status_text = "No PNG sprite frames were found in that folder.";
        status_is_error = true;
        return false;
    }

    if (array_length(preview_sprites) == 0)
    {
        var fallback_sprite = sprite_add(preview_path, 1, false, false, 0, 0);

        if (sprite_exists(fallback_sprite))
        {
            sprite_set_offset(
                fallback_sprite,
                sprite_get_width(fallback_sprite) * 0.5,
                sprite_get_height(fallback_sprite) * 0.5
            );

            array_push(preview_sprites, fallback_sprite);
        }
    }

    if (array_length(preview_sprites) == 0)
    {
        status_text = "The sprite frames could not be loaded.";
        status_is_error = true;
        return false;
    }

    preview_sprite = preview_sprites[0];

    status_text = "Sprite selected: " + selected_folder_name + " (" + string(array_length(preview_sprites)) + " frames)";
    status_is_error = false;
    return true;
};

create_new_attack = function()
{
    attack_name = string_trim(attack_name);

    if (attack_name == "")
    {
        status_text = "Enter an attack name.";
        status_is_error = true;
        name_focused = true;
        keyboard_string = attack_name;
        return false;
    }

    // Attack names become GML function names, so accept only valid identifier
    // characters and require a non-numeric first character.
    for (var i = 1; i <= string_length(attack_name); i++)
    {
        var ch = string_char_at(attack_name, i);
        var valid = string_letters(ch) != "" || string_digits(ch) != "" || ch == "_";

        if (!valid || (i == 1 && string_digits(ch) != ""))
        {
            status_text = "Use letters, numbers, and underscores; do not start with a number.";
            status_is_error = true;
            return false;
        }
    }

    if (selected_folder_path == "" || selected_folder_name == "")
    {
        status_text = "Select the folder containing the sprite frames.";
        status_is_error = true;
        return false;
    }

    if (!variable_global_exists("mod_root") || !directory_exists(global.mod_root))
    {
        status_text = "The selected mod folder is no longer available.";
        status_is_error = true;
        return false;
    }

    // Avoid silently replacing another attack anywhere in the mod.
    var attack_files = scr_collect_attack_gmls(global.mod_root);

    for (var f = 0; f < array_length(attack_files); f++)
    {
        if (string_lower(scr_get_attack_key_from_gml_path(attack_files[f])) == string_lower(attack_name))
        {
            status_text = "An attack named " + attack_name + " already exists.";
            status_is_error = true;
            return false;
        }
    }

    // Dispose any old dynamic frames before the loader replaces the array.
    if (variable_global_exists("loaded_frame_sprites"))
    {
        for (var old = 0; old < array_length(global.loaded_frame_sprites); old++)
        {
            if (sprite_exists(global.loaded_frame_sprites[old]))
            {
                sprite_delete(global.loaded_frame_sprites[old]);
            }
        }

        global.loaded_frame_sprites = [];
    }

    if (!scr_load_sprite_folder_frames(selected_folder_path, selected_folder_name))
    {
        status_text = "Use sequential PNG frames (name_0.png or 0000.png).";
        status_is_error = true;
        return false;
    }

    var new_attack = {
        version: 1,
        sprite: selected_folder_name,
        name: attack_name,
        phases: [
            {
                lasts: "3",
                frames: [
                    {
                        frame: "3",
                        animationFrame: 0,
                        hitboxes: []
                    }
                ]
            },
            { lasts: "3", frames: [] },
            { lasts: "3", frames: [] }
        ]
    };

    var save_root = scr_normalize_folder_path(game_save_id);
    var json_dir = save_root + "attack_json/";

    if (!directory_exists(json_dir))
    {
        directory_create(json_dir);
    }

    var json_path = json_dir + selected_folder_name + ".json";
    var mod_root = scr_normalize_folder_path(global.mod_root);
    var scripts_dir = mod_root + "scripts/";

    if (!directory_exists(scripts_dir) && directory_exists(mod_root + "Scripts/"))
    {
        scripts_dir = mod_root + "Scripts/";
    }

    var gml_path = scripts_dir + "gml_GlobalScript_" + attack_name + ".gml";

    global.selected_sprite_folder_name = selected_folder_name;
    global.selected_sprite_folder_path = selected_folder_path;
    global.selected_gml_path = gml_path;
    global.selected_attack_gml_path = gml_path;
    global.selected_attack_name = attack_name;
    global.current_attack_json_path = json_path;
    global.current_attack_data = new_attack;
    global.timeline = scr_build_timeline_from_attack(new_attack);
    global.current_timeline_frame = 0;
    global.attack_json_dirty = true;

    if (!scr_save_current_attack_json())
    {
        status_text = "The new attack JSON could not be saved.";
        status_is_error = true;
        return false;
    }

    // Materialize the initial GML immediately; later edits continue to use the
    // editor's normal Save button and this same destination path.
    scr_run_json_to_gml_converter(json_path, gml_path);

    close_new_attack_window();
    room_goto(main_app);
    return true;
};
