/*
Preview Canvas Size and Position for ref

canvas_x = 420;
canvas_y = 80;
canvas_w = 520;
canvas_h = 320;

*/

panel_x = ref_hitbox_panel.x;
panel_y = ref_hitbox_panel.y;
panel_w = 600;
panel_h = 800;

timeline = undefined;

input_labels = [
    "Hitbox type:",
    "X",
    "Y",
    "X Scale:",
    "Y Scale:",
    "Damage:",
    "Base Knockback:",
    "Knockback Scale:",
    "Hitlag:",
    "Angle:",
    "Duration:",
    "vfxStyle:",
    "sfx:"
];



// Helper for creating a text input


function create_hitbox_panel_input(_input_id, _x, _y, _xscale)
{
    var inst = instance_create_layer(_x, _y, "Instances", obj_text_input);

    with (inst)
    {
        image_xscale = _xscale;
        image_yscale = 1;

        scr_setup_text_input(_input_id, "hitbox");
    }

    return inst;
}


// Hitbox type dropdown
// ID 0
var text_y = panel_y + 97;

create_hitbox_panel_input(
    0,
    panel_x + string_length(input_labels[0]) * 11,
    text_y,
    7
);
/*
// X / Y
// IDs 1 and 2

text_y += 35;

create_hitbox_panel_input(1, panel_x + 160, text_y, 2.5);
create_hitbox_panel_input(2, panel_x + 260, text_y, 2.5);

// X Scale / Y Scale
// IDs 3 and 4
text_y += 35;

create_hitbox_panel_input(3, panel_x + 160, text_y, 2.5);
create_hitbox_panel_input(4, panel_x + 260, text_y, 2.5);

// Other hitbox properties
// IDs 5 through 12


for (var i = 5; i <= array_length(input_labels) - 1; i++)
{
    text_y = panel_y + 65 + i * 35;

    create_hitbox_panel_input(
        i,
        panel_x + 180,
        text_y,
        5
    );
}