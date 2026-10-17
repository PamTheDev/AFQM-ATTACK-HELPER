if (!global.context_active) exit;
refresh_layout();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var old_color = draw_get_color();
var old_alpha = draw_get_alpha();
var old_halign = draw_get_halign();
var old_valign = draw_get_valign();
draw_set_halign(fa_left);
draw_set_valign(fa_top);
for (var i = 0; i < array_length(menu_panels); i++)
{
    var panel = menu_panels[i];
    draw_set_color(c_black);
    draw_set_alpha(0.25);
    draw_rectangle(panel.x - 4, panel.y - 4, panel.x + menu_w + 4, panel.y + panel.height + 4, false);
    draw_set_alpha(1);
    draw_set_color(merge_colour(c_gray, c_dkgray, 0.5));
    draw_rectangle(panel.x, panel.y, panel.x + menu_w, panel.y + panel.height, false);
    draw_set_color(c_white);
    draw_rectangle(panel.x, panel.y, panel.x + menu_w, panel.y + panel.height, true);
}
for (var i = 0; i < array_length(menu_rows); i++)
{
    var row = menu_rows[i];
    var enabled = scr_context_menu_input_enabled(row.input);
    if (row.separator)
    {
        draw_set_color(c_dkgray);
        draw_line(row.x + 5, row.y - section_gap / 2, row.x + menu_w - 5, row.y - section_gap / 2);
    }
    if (enabled && point_in_rectangle(mx, my, row.x, row.y, row.x + menu_w, row.y + menu_h))
    {
        draw_set_color(c_gray);
        draw_rectangle(row.x, row.y, row.x + menu_w, row.y + menu_h, false);
    }
    draw_set_color(enabled ? c_white : c_gray);
    draw_text(row.x + 8, row.y + 7, row.input.label);
}
draw_set_color(old_color);
draw_set_alpha(old_alpha);
draw_set_halign(old_halign);
draw_set_valign(old_valign);
