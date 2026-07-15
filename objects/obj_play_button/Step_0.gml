if (global.playing_animation)
{
	anim_frame = 1;
    if (variable_global_exists("timeline"))
    {
        if (!is_undefined(global.timeline))
        {
            var frame_time = 1 / animation_play_fps;

            animation_play_timer += delta_time / 1000000;

            while (animation_play_timer >= frame_time)
            {
                animation_play_timer -= frame_time;

                global.current_timeline_frame += 1;

                if (global.current_timeline_frame >= global.timeline.total_frames)
                {
                    global.current_timeline_frame = 0;
                }
            }
        }
    }
}
else
{
    animation_play_timer = 0;
	anim_frame = 0;
}