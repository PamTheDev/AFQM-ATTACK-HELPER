var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

var box_w = 520;
var box_h = 120;

var box_x = gui_w * 0.5 - box_w * 0.5;
var box_y = gui_h * 0.5 - box_h * 0.5;

draw_set_alpha(0.85);
draw_set_color(c_black);
draw_rectangle(box_x, box_y, box_x + box_w, box_y + box_h, false);

draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(box_x, box_y, box_x + box_w, box_y + box_h, true);

draw_text(box_x + 24, box_y + 20, load_text);

var bar_x = box_x + 24;
var bar_y = box_y + 64;
var bar_w = box_w - 48;
var bar_h = 24;

draw_set_color(c_dkgray);
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);

draw_set_color(c_lime);
draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_w * load_progress,
    bar_y + bar_h,
    false
);

draw_set_color(c_white);
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, true);

var percent = round(load_progress * 100);
draw_text(bar_x, bar_y + 32, string(percent) + "%");