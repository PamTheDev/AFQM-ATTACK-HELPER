// obj_mod_folder_loader Step Event

if (last_loader_state != loader_state)
{
    last_loader_state = loader_state;
    show_debug_message("Loader state changed to: " + loader_state);
}



// FIND SPRITE ROOT


if (loader_state == "find_sprite_root")
{
    load_text = "Finding sprite folder...";
    load_progress = 0.01;

    if (!variable_global_exists("mod_root"))
    {
        load_error = "ERROR: global.mod_root does not exist.";
        loader_state = "error";
        exit;
    }

    mod_root = scr_normalize_folder_path(global.mod_root);
    sprite_root = scr_find_sprite_folder_root(mod_root);

    if (sprite_root == "")
    {
        load_error = "ERROR: Could not find sprite folder root.";
        loader_state = "error";
        exit;
    }

    sprite_root = scr_normalize_folder_path(sprite_root);

    show_debug_message("Sprite root found:");
    show_debug_message(sprite_root);

	png_files = scr_collect_sprite_png(sprite_root);
    gif_files = scr_collect_sprite_gifs(sprite_root);
	image_files = array_concat(gif_files, png_files);
    gif_index = 0;
    gif_conversion_started = false;
    gif_wait_frames = 0;

    show_debug_message("GIF files found:");
    show_debug_message(string(array_length(image_files)));

    if (array_length(image_files) > 0)
    {
        loader_state = "convert_gifs";
    }
    else
    {
        loader_state = "start_attack_scan";
    }

    exit;
}



// CONVERT GIFS


if (loader_state == "convert_gifs")
{
    var gif_total = array_length(image_files);

    if (gif_total <= 0)
    {
        loader_state = "start_attack_scan";
        exit;
    }

    if (gif_index >= gif_total)
    {
        show_debug_message("All GIF conversions finished.");
        loader_state = "start_attack_scan";
        exit;
    }

    var gif_path = image_files[gif_index];
    var done_path = scr_get_gif_conversion_done_path(gif_path, sprite_root);

    load_text = "Converting GIF " + string(gif_index + 1) + " / " + string(gif_total);
    load_progress = 0.05 + 0.30 * (gif_index / gif_total);

    if (!gif_conversion_started)
    {
        show_debug_message("Starting GIF conversion:");
        show_debug_message(gif_path);

        show_debug_message("Expected done file:");
        show_debug_message(done_path);

        if (file_exists(done_path))
        {
            file_delete(done_path);
        }

        var started = scr_run_gif_converter(gif_path, sprite_root);

        if (started)
        {
            gif_conversion_started = true;
            gif_wait_frames = 0;

            show_debug_message("GIF converter started.");
        }
        else
        {
            show_debug_message("ERROR: GIF converter did not start. Skipping:");
            show_debug_message(gif_path);

            gif_index += 1;
            gif_conversion_started = false;
            gif_wait_frames = 0;
        }
    }
    else
    {
        gif_wait_frames += 1;

        if (file_exists(done_path))
        {
            show_debug_message("GIF conversion finished:");
            show_debug_message(gif_path);

            gif_index += 1;
            gif_conversion_started = false;
            gif_wait_frames = 0;

            load_progress = 0.05 + 0.30 * (gif_index / gif_total);
        }
        else if (gif_wait_frames >= gif_wait_max)
        {
            show_debug_message("ERROR: GIF conversion timed out.");
            show_debug_message("GIF:");
            show_debug_message(gif_path);
            show_debug_message("Expected done file:");
            show_debug_message(done_path);

            gif_index += 1;
            gif_conversion_started = false;
            gif_wait_frames = 0;
        }
        else
        {
            if (gif_wait_frames mod room_speed == 0)
            {
                show_debug_message("Still waiting for GIF conversion...");
                show_debug_message("GIF:");
                show_debug_message(gif_path);
                show_debug_message("Expected done file:");
                show_debug_message(done_path);
            }
        }
    }

    exit;
}



// START ATTACK GML SCAN


if (loader_state == "start_attack_scan")
{
    load_text = "Finding attack scripts...";
    load_progress = 0.35;

    attack_gml_files = scr_collect_attack_gmls(mod_root);
    valid_index = 0;

    show_debug_message("GlobalScript GML files found:");
    show_debug_message(string(array_length(attack_gml_files)));

    loader_state = "check_attack_gml";

    exit;
}



// VALIDATE ATTACK GML AND MATCH SPRITE FOLDERS


if (loader_state == "check_attack_gml")
{
    var total_found = array_length(attack_gml_files);

    if (total_found <= 0)
    {
        load_error = "No GlobalScript GML files were found.";
        loader_state = "error";
        exit;
    }

    load_text = "Checking attack scripts... " + string(valid_index + 1) + " / " + string(total_found);
    load_progress = 0.45 + 0.35 * (valid_index / total_found);

    var amount = min(gml_checks_per_step, total_found - valid_index);

    repeat (amount)
    {
        var related_gml_path = attack_gml_files[valid_index];

        if (scr_is_attack_gml(related_gml_path))
        {
            var attack_name = scr_get_attack_key_from_gml_path(related_gml_path);
            var folder_name = "spr_" + attack_name;
            var folder_path = scr_normalize_folder_path(sprite_root + folder_name);

            if (attack_name != "")
            {
                array_push(global.sprite_folders, {
                    name: folder_name,
                    path: folder_path,
                    gml_path: related_gml_path,
                    attack_name: attack_name
                });

                global.sprite_folder_count += 1;

                show_debug_message("Valid attack:");
                show_debug_message(attack_name);
                show_debug_message("Sprite folder:");
                show_debug_message(folder_path);
                show_debug_message("GML:");
                show_debug_message(related_gml_path);

                if (!directory_exists(folder_path))
                {
                    show_debug_message("Sprite folder is missing; attack button will still be created:");
                    show_debug_message(folder_path);
                }
            }
        }
        else
        {
            show_debug_message("Skipping non-attack GML:");
            show_debug_message(related_gml_path);
        }

        valid_index += 1;

        if (valid_index >= total_found)
        {
            break;
        }
    }

    if (valid_index >= total_found)
    {
        show_debug_message("Valid attacks found:");
        show_debug_message(string(global.sprite_folder_count));

        if (global.sprite_folder_count <= 0)
        {
            load_error = "No valid attack scripts were found.";
            loader_state = "error";
            exit;
        }

        // Save quick-load cache after a successful full scan.
        scr_save_last_mod_cache(
            mod_root,
            sprite_root,
            global.sprite_folders
        );

        create_index = 0;
        loader_state = "create_buttons";
    }

    exit;
}



// CREATE BUTTONS


if (loader_state == "create_buttons")
{
    var total_buttons = global.sprite_folder_count;

    if (total_buttons <= 0)
    {
        load_error = "No valid attack scripts found.";
        loader_state = "error";
        exit;
    }

    load_text = "Creating buttons... " + string(create_index) + " / " + string(total_buttons);
    load_progress = 0.80 + 0.20 * (create_index / total_buttons);

    var amount = min(buttons_per_step, total_buttons - create_index);

    repeat (amount)
    {
        var col = create_index div buttons_per_column;
        var row = create_index mod buttons_per_column;

        var bx = button_start_x + col * (button_w + button_gap_x);
        var by = button_start_y + row * (button_h + button_gap_y);

        var btn = instance_create_layer(bx, by, "Instances", obj_sprite_folder_button);

        btn.button_width = button_w;
        btn.button_height = button_h;

        btn.sprite_folder_index = create_index;
        btn.sprite_folder_name = global.sprite_folders[create_index].name;
        btn.sprite_folder_path = global.sprite_folders[create_index].path;
        btn.related_gml_path = global.sprite_folders[create_index].gml_path;

        if (variable_struct_exists(global.sprite_folders[create_index], "attack_name"))
        {
            btn.attack_name = global.sprite_folders[create_index].attack_name;
        }

        create_index += 1;

        if (create_index >= total_buttons)
        {
            break;
        }
    }

    if (create_index >= total_buttons)
    {
        load_text = "Done.";
        load_progress = 1;
        loader_state = "done";
    }

    exit;
}



// DONE


if (loader_state == "done")
{
    load_progress = 1;
    global.loading_sprite_buttons = false;

    done_timer -= 1;

    if (done_timer <= 0)
    {
        instance_destroy();
    }

    exit;
}



// ERROR


if (loader_state == "error")
{
    load_text = load_error;
    load_progress = 1;
    global.loading_sprite_buttons = false;

    if (file_search_active)
    {
        file_find_close();
        file_search_active = false;
    }

    show_debug_message(load_error);

    // Keep the loader visible instead of instantly destroying it.
    // Press Escape to close the error overlay.
    if (keyboard_check_pressed(vk_escape))
    {
        instance_destroy();
    }

    exit;
}
