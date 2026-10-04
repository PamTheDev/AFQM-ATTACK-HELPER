if (!global.context_active) exit;
refresh_layout();
var cx = global.context_x;
var cy = global.context_y;
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var old_color = draw_get_color();
var old_alpha = draw_get_alpha();
var old_halign = draw_get_halign();
var old_valign = draw_get_valign();
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_set_alpha(0.25);
draw_rectangle(cx - 5, cy - 5, cx + menu_w + 5, cy + menu_height + 5, false);
draw_set_alpha(1);
draw_set_color(merge_colour(c_gray, c_dkgray, 0.5));
draw_rectangle(cx, cy, cx + menu_w, cy + menu_height, false);

for (var i = 0; i < array_length(menu_rows); i++)
{
    var row = menu_rows[i];
    var row_top = cy + row.top;
    var enabled = scr_context_menu_input_enabled(row.input);
    var hovered = point_in_rectangle(mx, my, cx, row_top, cx + menu_w, row_top + menu_h);
    if (row.separator)
    {
        draw_set_color(c_dkgray);
        draw_line(cx + 5, row_top - section_gap / 2, cx + menu_w - 5, row_top - section_gap / 2);
    }
    if (hovered && enabled)
    {
        draw_set_color(c_gray);
        draw_rectangle(cx, row_top, cx + menu_w, row_top + menu_h, false);
    }
    draw_set_color(enabled ? c_white : c_gray);
    draw_text(cx + 8, row_top + 7, row.input.label);
}
draw_set_color(c_white);
draw_rectangle(cx, cy, cx + menu_w, cy + menu_height, true);
draw_set_color(old_color);
draw_set_alpha(old_alpha);
draw_set_halign(old_halign);
draw_set_valign(old_valign);
