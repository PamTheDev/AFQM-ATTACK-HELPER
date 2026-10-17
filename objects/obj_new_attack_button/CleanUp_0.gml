global.new_attack_window_open = false;

for (var i = 0; i < array_length(preview_sprites); i++)
{
    if (sprite_exists(preview_sprites[i]))
    {
        sprite_delete(preview_sprites[i]);
    }
}

preview_sprites = [];
preview_sprite = -1;

if (surface_exists(preview_surface))
{
    surface_free(preview_surface);
    preview_surface = -1;
}
