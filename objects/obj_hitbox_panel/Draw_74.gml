if (variable_global_exists("menu_focus"))
	var _focus = global.menu_focus

draw_set_color(make_color_rgb(70, 70, 70));
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);

draw_set_color(make_color_rgb(50, 50, 50));
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + 75, false);

draw_set_colour(c_white);
draw_text_transformed(panel_x+10, panel_y + 27, "Edit Panel",2,2,0)
if (variable_global_exists("menu_focus"))
{
switch (_focus) {
	default:
		break;
	case "hitbox":
	draw_set_colour(c_white)
//Hitbox, X and Y labels
	var text_y = panel_y + 100
	draw_text(panel_x + 20, text_y, input_labels[0])

	text_y += 35
	draw_text(panel_x + 20, text_y, "Position:")
	draw_text(panel_x + 140, text_y, "X")
	draw_text(panel_x + 245, text_y, "Y")

	text_y += 35
	draw_text(panel_x + 20, text_y, "Scale:")
	draw_text(panel_x + 140, text_y, "X")
	draw_text(panel_x + 245, text_y, "Y")

	for (var i = 5; i <= array_length(input_labels)-1; i++)
	{
		text_y = panel_y + 70 + i*35
		draw_text(panel_x + 20, text_y, input_labels[i])
	}
	break;

}
}