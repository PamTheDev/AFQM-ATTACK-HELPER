if global.selected_sprite_folder_path == sprite_folder_path
	draw_set_colour(merge_colour(c_ltgray,c_yellow, 0.4))
else if (hovered)
    draw_set_color(c_ltgray);
else
    draw_set_color(c_gray);

draw_rectangle(x, y, x + button_width, y + button_height, false);

draw_set_color(c_white);
draw_text(x + 12, y + 12, sprite_folder_name);
if (my_sprite != -1)
{
    draw_sprite(my_sprite, 0, x + 8, y + 8);
}