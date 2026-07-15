// obj_loader_guard Create Event

show_debug_message("Loader guard created. Destroying old loaders.");

// Destroy every existing mod folder loader
with (obj_mod_folder_loader)
{
    instance_destroy();
}

// Optional: also destroy the old loader object if it still exists in the room
with (obj_generate_buttons)
{
    instance_destroy();
}

// Wait a few frames before creating the new loader
alarm[0] = 3;