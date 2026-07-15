if (is_undefined(timeline))
{
    exit;
}

scr_timeline_ensure_phases(timeline);



// Layout


var phase_area_h = phase_label_height + phase_bracket_height + phase_tag_gap + 4;
var ruler_y = phase_area_h;
var local_track_start_y = phase_area_h + ruler_h;
var track_start_y = timeline_y + local_track_start_y;

var content_x = timeline_x + header_w;
var content_y = timeline_y;
var content_w = timeline_w - header_w;
var content_h = timeline_h;



// Create / recreate masked timeline surface


if (!surface_exists(timeline_surface))
{
    timeline_surface = surface_create(content_w, content_h);
}

if (surface_exists(timeline_surface))
{
    if (surface_get_width(timeline_surface) != content_w || surface_get_height(timeline_surface) != content_h)
    {
        surface_free(timeline_surface);
        timeline_surface = surface_create(content_w, content_h);
    }
}



// Main timeline background


draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(timeline_x, timeline_y, timeline_x + timeline_w, timeline_y + timeline_h, false);



// Header / track labels, not masked


draw_set_color(make_color_rgb(20, 20, 20));
draw_rectangle(timeline_x, timeline_y, timeline_x + header_w, timeline_y + local_track_start_y, false);

draw_set_color(c_white);
draw_text(timeline_x + 8, timeline_y + 6, "Phases");

var row_y = 0;

for (var t = 0; t < array_length(timeline.tracks); t++)
{
    row_y = track_start_y + t * track_h - scroll_y;

    if (row_y + track_h < timeline_y || row_y > timeline_y + timeline_h)
    {
        continue;
    }

    draw_set_color(make_color_rgb(35, 35, 35));
    draw_rectangle(timeline_x, row_y, timeline_x + header_w, row_y + track_h, false);

    draw_set_color(c_white);
    draw_text(timeline_x + 8, row_y + 7, timeline.tracks[t].name);
}


// New Track label
row_y = track_start_y + array_length(timeline.tracks) * track_h - scroll_y;

if (row_y + track_h >= timeline_y && row_y <= timeline_y + timeline_h)
{
    draw_set_color(make_color_rgb(15, 15, 15));
    draw_rectangle(timeline_x, row_y, timeline_x + header_w, row_y + track_h, false);

    draw_set_color(c_gray);
    draw_text(timeline_x + 8, row_y + 7, "New Track");
}



// Draw masked frame area to surface


surface_set_target(timeline_surface);

draw_clear_alpha(c_black, 0);


// Frame area background
draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(0, 0, content_w, content_h, false);



// Phase tags / brackets


scr_draw_timeline_phase_tags(
    timeline,
    scroll_x,
    frame_w,
    content_w,
    phase_label_height,
    phase_bracket_height,
    selected_phase_index
);



// Frame ruler background


draw_set_color(make_color_rgb(45, 45, 45));
draw_rectangle(0, ruler_y, content_w, ruler_y + ruler_h, false);



// Track row backgrounds in masked area


for (var t = 0; t < array_length(timeline.tracks); t++)
{
    var local_row_y = local_track_start_y + t * track_h - scroll_y;

    if (local_row_y + track_h < 0 || local_row_y > content_h)
    {
        continue;
    }

    if (t mod 2 == 0)
    {
        draw_set_color(make_color_rgb(22, 22, 22));
    }
    else
    {
        draw_set_color(make_color_rgb(18, 18, 18));
    }

    if (drag_mode == "move" && drag_current_drop_track == t)
    {
        if (timeline.tracks[t].type == "hitbox")
        {
            draw_set_color(make_color_rgb(35, 35, 35));
        }
    }

    draw_rectangle(0, local_row_y, content_w, local_row_y + track_h, false);
}



// Frame ruler and vertical frame lines


for (var f = 0; f <= timeline.total_frames; f++)
{
    var fx = f * frame_w - scroll_x;

    if (fx < 0 || fx > content_w)
    {
        continue;
    }

    draw_set_color(make_color_rgb(80, 80, 80));
    draw_line(fx, ruler_y, fx, content_h);

    if (f mod 5 == 0)
    {
        draw_set_color(c_white);
        draw_text(fx + 2, ruler_y + 4, string(f));
    }
}



// Keys / frame blocks


var _frame_num = 0;

for (var t = 0; t < array_length(timeline.tracks); t++)
{
    var track = timeline.tracks[t];
    var local_row_y = local_track_start_y + t * track_h - scroll_y;

    if (local_row_y + track_h < 0 || local_row_y > content_h)
    {
        continue;
    }

    for (var k = 0; k < array_length(track.keys); k++)
    {
        _frame_num++;

        var key = track.keys[k];

        var key_x = key.start * frame_w - scroll_x;
        var key_w = max(4, key.duration * frame_w);

        if (track.type == "animation")
        {
            key_w = max(4, frame_w);
        }

        if (key_x + key_w < 0 || key_x > content_w)
        {
            continue;
        }

var key_is_selected = false;

if (selected_track == t && selected_key == k)
{
    key_is_selected = true;
}

if (variable_global_exists("selected_hitbox_key"))
{
    if (!is_undefined(global.selected_hitbox_key))
    {
        if (key == global.selected_hitbox_key)
        {
            key_is_selected = true;
        }
    }
}

if (key_is_selected)
{
    draw_set_color(make_color_rgb(255, 180, 60));
}
else if (track.type == "animation")
{
    draw_set_color(make_color_rgb(80, 120, 255));
}
else if (track.type == "hitbox")
{
    if (variable_struct_exists(key, "hitbox"))
    {
        draw_set_color(merge_colour(scr_get_hitbox_color(key.hitbox), c_gray, 0.4));
    }
    else
    {
        draw_set_color(c_dkgray);
    }
}
else
{
    draw_set_color(make_color_rgb(255, 80, 80));
}

        var original_color = draw_get_color();

        if (_frame_num mod 2 == 0)
        {
            draw_set_color(merge_colour(original_color, c_black, 0.4));
        }

        draw_rectangle(
            key_x,
            local_row_y + 4,
            key_x + key_w,
            local_row_y + track_h - 4,
            false
        );

        if (track.type == "animation")
        {
            draw_triangle(
                key_x + key_w,
                local_row_y + 4,
                key_x + key_w,
                local_row_y + track_h - 4,
                key_x + key_w * 1.5,
                local_row_y + track_h / 2,
                false
            );
        }

        draw_set_color(c_white);

        var key_text = "";

        if (track.type == "animation")
        {
            key_text = string(key.animation_frame);
        }
        else if (track.type == "hitbox")
        {
            if (variable_struct_exists(key, "hitbox"))
            {
                key_text = scr_get_hitbox_text(key.hitbox);
            }
            else
            {
                key_text = "?";
            }
        }
        else
        {
            key_text = "er";
        }

        draw_text(key_x + 4, local_row_y + 7, key_text);

        // Resize handle
        if (track.type != "animation")
        {
            draw_set_color(c_white);
            draw_rectangle(
                key_x + key_w - 4,
                local_row_y + 4,
                key_x + key_w,
                local_row_y + track_h - 4,
                false
            );
        }
    }
}



// Playhead, masked


if (variable_global_exists("current_timeline_frame"))
{
    var playhead_x = global.current_timeline_frame * frame_w - scroll_x;

    if (playhead_x >= 0 && playhead_x <= content_w)
    {
        draw_set_color(c_lime);
        draw_line(playhead_x, ruler_y, playhead_x, content_h);

        draw_set_color(c_white);
        draw_triangle(
            playhead_x - 7,
            ruler_y,
            playhead_x + 7,
            ruler_y,
            playhead_x,
            ruler_y + 7,
            false
        );
    }
}



// Finish masked surface


surface_reset_target();

draw_set_alpha(1);
draw_surface(timeline_surface, content_x, content_y);



// Borders on top


draw_set_color(make_color_rgb(60, 60, 60));
draw_rectangle(timeline_x, timeline_y, timeline_x + timeline_w, timeline_y + timeline_h, true);

draw_set_color(make_color_rgb(80, 80, 80));
draw_line(content_x, timeline_y, content_x, timeline_y + timeline_h);