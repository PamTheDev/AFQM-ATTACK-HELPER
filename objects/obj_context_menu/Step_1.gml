// Capture before any normal Step event so menu clicks cannot also select
// the folder underneath, regardless of instance event order.
global.context_click_consumed = false;
if (!global.context_active) exit;
refresh_layout();
global.context_click_consumed = mouse_check_button_pressed(mb_left)
    && point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
        global.context_x, global.context_y,
        global.context_x + menu_w, global.context_y + menu_height);
