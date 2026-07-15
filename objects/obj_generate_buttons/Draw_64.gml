if (loader_state == "done" && done_timer <= 0)
{
    exit;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

var box_w = 560;
var box_h = 145;

var box_x = gui_w * 0.5 - box_w * 0.5;
var box_y = gui_h * 0.5 - box_h * 0.5;

draw_set_alpha(0.9);
draw_set_color(c_black);
draw_rectangle(box_x, box_y, box_x + box_w, box_y + box_h, false);

draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(box_x, box_y, box_x + box_w, box_y + box_h, true);

var text_to_draw = loader_text;

if (loader_state == "error")
{
    text_to_draw = loader_error;
}

draw_set_color(c_white);
draw_text(box_x + 24, box_y + 20, text_to_draw);

draw_set_color(c_white);
draw_text(box_x + 24, box_y + box_h - 20, debug_message);

var bar_x = box_x + 24;
var bar_y = box_y + 68;
var bar_w = box_w - 48;
var bar_h = 24;

draw_set_color(c_dkgray);
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);

var progress = clamp(loader_progress, 0, 1);

if (loader_state == "error")
{
    draw_set_color(c_red);
}
else
{
    draw_set_color(c_lime);
}

draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_w * progress,
    bar_y + bar_h,
    false
);

draw_set_color(c_white);
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, true);

var percent = round(progress * 100);
draw_text(bar_x, bar_y + 34, string(percent) + "%");

draw_set_alpha(1);