if (!variable_global_exists("playing_animation"))
{
    global.playing_animation = false;
}

time_between_frames = 0.01666666667;

animation_play_fps = 60;
animation_play_timer = 0;

anim_frame = 0;