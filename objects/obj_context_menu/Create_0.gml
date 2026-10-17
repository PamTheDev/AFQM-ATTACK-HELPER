scr_context_menu_init();
scr_context_menu_close();
global.context_click_consumed = false;
mouse_over_context = false;
depth = -10000;
menu_w = 240;
menu_h = 30;
section_gap = 8;
menu_height = 0;
menu_rows = [];
menu_panels = [];
refresh_layout = function()
{
    menu_w = 190;
    for (var i = 0; i < array_length(global.context_items); i++)
    {
        var item = global.context_items[i];
        menu_w = max(menu_w, string_width(item.label) + 24);
        if (variable_struct_exists(item, "children"))
            for (var k = 0; k < array_length(item.children); k++)
                menu_w = max(menu_w, string_width(item.children[k].label) + 24);
    }
    menu_rows = [];
    menu_panels = [];
    menu_height = 0;
    var previous_section = undefined;
    for (var i = 0; i < array_length(global.context_items); i++)
    {
        var entry = global.context_items[i];
        var separator = i > 0 && entry.section != previous_section;
        if (separator) menu_height += section_gap;
        array_push(menu_rows, { input: entry, top: menu_height, separator: separator, index: i, child: false });
        menu_height += menu_h;
        previous_section = entry.section;
    }
    global.context_x = clamp(global.context_x, 0, max(0, display_get_gui_width() - menu_w));
    global.context_y = clamp(global.context_y, 0, max(0, display_get_gui_height() - menu_height));
    array_push(menu_panels, { x: global.context_x, y: global.context_y, height: menu_height });
    for (var i = 0; i < array_length(menu_rows); i++)
    {
        menu_rows[i].x = global.context_x;
        menu_rows[i].y = global.context_y + menu_rows[i].top;
    }
    var parent = global.context_submenu;
    if (parent >= 0 && parent < array_length(global.context_items))
    {
        var children = global.context_items[parent].children;
        var height = array_length(children) * menu_h;
        var cx = global.context_x + menu_w;
        if (cx + menu_w > display_get_gui_width()) cx = max(0, global.context_x - menu_w);
        var cy = clamp(menu_rows[parent].y, 0, max(0, display_get_gui_height() - height));
        array_push(menu_panels, { x: cx, y: cy, height: height });
        for (var i = 0; i < array_length(children); i++)
            array_push(menu_rows, { input: children[i], x: cx, y: cy + i * menu_h, separator: false, index: i, child: true });
    }
};
context_contains_mouse = function()
{
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    for (var i = 0; i < array_length(menu_panels); i++)
    {
        var panel = menu_panels[i];
        if (point_in_rectangle(mx, my, panel.x, panel.y, panel.x + menu_w, panel.y + panel.height)) return true;
    }
    return false;
};
