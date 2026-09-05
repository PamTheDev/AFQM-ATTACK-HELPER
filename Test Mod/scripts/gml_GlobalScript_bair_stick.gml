function bair_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;

    if (argument_count > 0)
    {
        anim_sprite = spr_stick_bair;
        var _phase = argument[0];

        if (_phase == UnknownEnum.Value_m1)
        {
            prevPhase = -1;
            attack_phase = 0;
        }
        else
        {
            prevPhase = -1;
            attack_phase = _phase;
        }
    }
    else
    {
        attack_frame = max(--attack_frame, 0);

        if (attack_frame == 0)
        {
            prevPhase = -1;

            switch (attack_phase)
            {
                case 0:
                    attack_phase++;
                    break;

                case 1:
                    attack_phase++;
                    break;

                case 2:
                    attack_stop(UnknownEnum.Value_1);
                    run = false;
                    break;

            }
        }
    }

    friction_gravity(ground_friction, grav, max_fall_speed);

    if (run && cancel_air_check())
        run = false;

    while (run && (prevPhase != attack_phase || prevFrame != attack_frame))
    {
        if (prevPhase != attack_phase)
        {
            switch (attack_phase)
            {
                case 0:
                    attack_frame = 4;
                    break;

                case 1:
                    attack_frame = 13;
                    break;

                case 2:
                    attack_frame = 8;
                    break;

            }
        }

        prevPhase = attack_phase;
        prevFrame = attack_frame;

        switch (attack_phase)
        {
            case 0:
                switch (attack_frame)
                {
                    case 4:
                        anim_frame = 0;
                        break;

                }

                break;

            case 1:
                switch (attack_frame)
                {
                    case 13:
                        anim_frame = 1;
                        break;

                    case 9:
                        anim_frame = 2;
                        var hitbox1 = hitbox_create_melee(-18, 0, 0.84, 0.54, 11.2, 0, 0, 8, 148, 3, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_1;
                        hitbox1.hit_sfx = 29;
                        break;

                    case 6:
                        anim_frame = 3;
                        var hitbox1 = hitbox_create_melee(-15, 2, 0.74, 0.44, 5.3, 0, 0, 5, 128, 10, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_0;
                        hitbox1.hit_sfx = 29;
                        break;

                    case 0:
                        anim_frame = 4;
                        var hitbox1 = hitbox_create_melee(-15, 2, 0.74, 0.44, 5.3, 0, 0, 5, 128, 10, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_0;
                        hitbox1.hit_sfx = 29;
                        break;

                }

                break;

            case 2:
                switch (attack_frame)
                {
                    case 4:
                        anim_frame = 5;
                        break;

                }

                break;

        }
    }
    move_grounded();
}

enum UnknownEnum
{
    Value_m2 = -2,
    Value_m1,
    Value_1 = 1,
    Value_4 = 4
}
