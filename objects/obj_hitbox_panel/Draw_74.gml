var _focus = "default";
if (variable_global_exists("menu_focus")) _focus = global.menu_focus;

draw_set_color(make_color_rgb(70, 70, 70));
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);

draw_set_color(make_color_rgb(50, 50, 50));
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + 75, false);

draw_set_colour(c_white);
draw_text_transformed(panel_x+10, panel_y + 27, "Edit Panel",2,2,0)
{
switch (_focus) {
	
    default:
    {
        var aerial_x = panel_x + 20;
        var aerial_y = panel_y + 95;
        var aerial_hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), aerial_x, aerial_y, aerial_x + 320, aerial_y + 42);
        draw_set_colour(aerial_hover ? make_color_rgb(80, 100, 125) : make_color_rgb(55, 70, 90));
        draw_rectangle(aerial_x, aerial_y, aerial_x + 320, aerial_y + 42, false);
        draw_set_colour(c_white);
        draw_rectangle(aerial_x, aerial_y, aerial_x + 320, aerial_y + 42, true);
        var aerial = variable_global_exists("timeline") && !is_undefined(global.timeline) && variable_struct_exists(global.timeline, "aerial") && global.timeline.aerial;
        draw_text(aerial_x + 14, aerial_y + 13, (aerial ? "[x] " : "[ ] ") + "Aerial move");
        break;
    }
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
		draw_text(panel_x + 20, panel_y + 100, "Flag Type:")

		var active_flag_type = scr_sync_selected_flag_submenu();
		var active_definition = scr_get_flag_type_definition_from_key(active_flag_type);

		if (active_flag_type == "custom_code")
		{
			draw_text(panel_x + 20, panel_y + 390, active_definition.inputs[0].label)
		}
		else if (array_length(active_definition.inputs) <= 0)
		{
			draw_text(panel_x + 20, panel_y + 160, "This flag has no inputs.")
		}
		else
		{
			for (var flag_input_index = 0; flag_input_index < array_length(active_definition.inputs); flag_input_index++)
			{
				draw_text(
					panel_x + 20,
					panel_y + 160 + flag_input_index * 40,
					active_definition.inputs[flag_input_index].label
				)
			}
		}

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

		var end_state_y1 = panel_y + 150;
		var end_state_y2 = end_state_y1 + 42;
		var end_state_hovered = point_in_rectangle(mx, my, button_x1, end_state_y1, button_x2, end_state_y2);
		var selected_phase = scr_get_selected_phase();
		var phase_end_state = scr_get_phase_attack_stop_state(selected_phase);

		draw_set_colour(end_state_hovered ? make_color_rgb(80, 100, 125) : make_color_rgb(55, 70, 90));
		draw_rectangle(button_x1, end_state_y1, button_x2, end_state_y2, false);
		draw_set_colour(c_white);
		draw_rectangle(button_x1, end_state_y1, button_x2, end_state_y2, true);
		draw_text(button_x1 + 14, end_state_y1 + 13, "Phase End State...  [" + phase_end_state + "]");

        var smash_y = panel_y + 205;
        draw_set_colour(make_color_rgb(55, 70, 90));
        draw_rectangle(button_x1, smash_y, button_x2, smash_y + 42, false);
        draw_set_colour(c_white);
        draw_rectangle(button_x1, smash_y, button_x2, smash_y + 42, true);
        draw_text(button_x1 + 14, smash_y + 13, (scr_phase_is_smash(selected_phase) ? "[x] " : "[ ] ") + "Smash attack");
		draw_text(panel_x + 20, panel_y + 390, "Phase Code:")
	}

}
}
