scr_context_menu_init();
scr_context_menu_close();
global.context_click_consumed = false;
mouse_over_context = false;
// Draw GUI End at a foreground depth.
depth = -10000;
menu_w = 150;
menu_h = 30;
section_gap = 8;
menu_height = 0;
menu_rows = [];

refresh_layout = function()
{
    menu_rows = [];
    menu_height = 0;
    var previous_section = undefined;
    for (var i = 0; i < array_length(global.context_items); i++)
    {
        var entry = global.context_items[i];
        var section = variable_struct_exists(entry, "section") ? entry.section : 1;
        var separator = i > 0 && section != previous_section;
        if (separator) menu_height += section_gap;
        array_push(menu_rows, { input: entry, top: menu_height, separator: separator });
        menu_height += menu_h;
        previous_section = section;
    }
    global.context_x = clamp(global.context_x, 0, max(0, display_get_gui_width() - menu_w));
    global.context_y = clamp(global.context_y, 0, max(0, display_get_gui_height() - menu_height));
};
