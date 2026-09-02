if (loader_state == "collect_folders")
{
    loader_text = "Scanning sprite folders... " + string(array_length(found_sprite_folders)) + " found";
    loader_progress = 0.05;

    var processed = 0;

    while (processed < scan_per_step)
    {
        if (found == "")
        {
            if (file_search_active)
            {
                file_find_close();
                file_search_active = false;
            }

            show_debug_message("Total sprite folders queued: " + string(array_length(found_sprite_folders)));

            valid_index = 0;
            loader_state = "find_related_gml";
            loader_progress = 0.15;

            break;
        }

        var folder_path = string_replace_all(found, "\\", "/");

        // Some GameMaker versions return only the folder name.
        if (string_pos("/", folder_path) == 0)
        {
            folder_path = sprite_root + folder_path;
        }

        folder_path = scr_normalize_folder_path(folder_path);

        if (directory_exists(folder_path))
        {
            var folder_name = scr_get_path_folder_name(folder_path);

            if (scr_starts_with(folder_name, "spr_"))
            {
                array_push(found_sprite_folders, {
                    name: folder_name,
                    path: folder_path
                });

                show_debug_message("Queued sprite folder:");
                show_debug_message(folder_name);
            }
        }

        found = file_find_next();
        processed += 1;
    }
}
else if (loader_state == "find_related_gml")
{
    var total_found = array_length(found_sprite_folders);

    if (total_found <= 0)
    {
        loader_text = "No sprite folders found.";
        loader_progress = 1;
        loader_state = "done";
        global.loading_sprite_buttons = false;
        exit;
    }

    var amount = min(gml_checks_per_step, total_found - valid_index);

    repeat (amount)
    {
        var folder_name = found_sprite_folders[valid_index].name;
        var folder_path = found_sprite_folders[valid_index].path;

        loader_text = "Finding sprite folders with scripts attatched. " + string(valid_index + 1) + " / " + string(total_found);

        var related_gml_path = scr_find_related_attack_gml(mod_root, folder_name);

        if (related_gml_path != "")
        {
            array_push(global.sprite_folders, {
                name: folder_name,
                path: folder_path,
                gml_path: related_gml_path
            });

            global.sprite_folder_count += 1;
			

            show_debug_message("Valid sprite folder:");
            show_debug_message(folder_name);
            show_debug_message("Related GML:");
            show_debug_message(related_gml_path);
			debug_message = "Found sprite folder: " + string(folder_name);
        }
        else
        {
            show_debug_message("Skipping sprite folder because no related GML was found:");
            show_debug_message(folder_name);
			debug_message = "Skipping sprite folder: " + string(folder_name);
        }

        valid_index += 1;

        if (valid_index >= total_found)
        {
            break;
        }
    }

    loader_progress = 0.15 + 0.65 * (valid_index / total_found);

    if (valid_index >= total_found)
    {
        show_debug_message("Valid sprite folders found: " + string(global.sprite_folder_count));

        create_index = 0;
        loader_state = "create_buttons";
        loader_progress = 0.80;
    }
}
else if (loader_state == "create_buttons")
{
    var total_buttons = global.sprite_folder_count;

    if (total_buttons <= 0)
    {
        loader_text = "No valid sprite folders found.";
        loader_progress = 1;
        loader_state = "done";
        global.loading_sprite_buttons = false;
        exit;
    }

    loader_text = "Creating buttons... " + string(create_index) + " / " + string(total_buttons);

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

        create_index += 1;

        if (create_index >= total_buttons)
        {
			
			break;
        }
    }
	/*
	    var col = create_index div buttons_per_column;
        var row = create_index mod buttons_per_column;

        var bx = button_start_x + col * (button_w + button_gap_x);
        var by = button_start_y + row * (button_h + button_gap_y);
*/

    if (create_index >= total_buttons)
    {
        loader_text = "Done. Created " + string(total_buttons) + " buttons.";
        loader_progress = 1;
        loader_state = "done";
        global.loading_sprite_buttons = false;
		var btn = instance_create_layer(0, 0, "Instances", obj_new_attack_button);

        btn.button_width = button_w;
        btn.button_height = button_h;

    }
}
else if (loader_state == "done")
{
    done_timer -= 1;

    if (done_timer <= 0)
    {
        instance_destroy();
    }
}
else if (loader_state == "error")
{
    global.loading_sprite_buttons = false;
}
