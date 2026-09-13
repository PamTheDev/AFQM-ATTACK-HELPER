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
	case "hitbox":{
		draw_set_colour(c_white)
		//Hitbox, X and Y labels
		var text_y = panel_y + 100
		draw_text(panel_x + 20, text_y, input_labels.hit[0])

		text_y += 35
		draw_text(panel_x + 20, text_y, "Position:")
		draw_text(panel_x + 140, text_y, "X")
		draw_text(panel_x + 245, text_y, "Y")

		text_y += 35
		draw_text(panel_x + 20, text_y, "Scale:")
		draw_text(panel_x + 140, text_y, "X")
		draw_text(panel_x + 245, text_y, "Y")

		for (var i = 5; i <= array_length(input_labels.hit)-1; i++)
		{
			text_y = panel_y + 70 + i*35
			draw_text(panel_x + 20, text_y, input_labels.hit[i])
		}
		break;
	}
	case "frame": {
		draw_set_colour(c_white)
		var text_y = panel_y + 100
		draw_text(panel_x + 20, text_y, input_labels.anim[0])
		text_y += 35
		draw_text(panel_x + 20, text_y, input_labels.anim[1])

		break;
	}
	case "flag": {
		draw_set_colour(c_white)
		var text_y = panel_y + 100
		draw_text(panel_x + 20, text_y, input_labels.anim[0])
		text_y += 35
		draw_text(panel_x + 20, text_y, input_labels.anim[1])

		break;
	}
	case "phase":{
		draw_set_colour(c_white)

		var button_x1 = panel_x + 20;
		var button_y1 = panel_y + 95;
		var button_x2 = button_x1 + 320;
		var button_y2 = button_y1 + 42;
		var mx = device_mouse_x_to_gui(0);
		var my = device_mouse_y_to_gui(0);
		var button_hovered = point_in_rectangle(mx, my, button_x1, button_y1, button_x2, button_y2);

		draw_set_colour(button_hovered ? make_color_rgb(80, 100, 125) : make_color_rgb(55, 70, 90));
		draw_rectangle(button_x1, button_y1, button_x2, button_y2, false);
		draw_set_colour(c_white);
		draw_rectangle(button_x1, button_y1, button_x2, button_y2, true);
		draw_text(button_x1 + 14, button_y1 + 13, "Attack Connected Checks...");

		draw_text(panel_x + 20, panel_y + 390, "Phase Code:")
	}

}
}
