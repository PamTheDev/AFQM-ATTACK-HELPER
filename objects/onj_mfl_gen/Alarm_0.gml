// obj_loader_guard Alarm 0 Event

if (!instance_exists(obj_mod_folder_loader))
{
    show_debug_message("No mod folder loader exists. Creating one.");

    instance_create_layer(0, 0, "Instances", obj_mod_folder_loader);
}
else
{
    show_debug_message("Mod folder loader already exists. Not creating another.");
}
instance_destroy();