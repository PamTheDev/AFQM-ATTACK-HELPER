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

input_labels = {
	hit :[
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
	],
	anim :[
	"On Frame:",
	"Animation Frame:"
	]
};



// Helper for creating a text input


function create_panel_input(_input_id, _x, _y, _xscale, _group)
{
    var inst = instance_create_layer(_x, _y, "Instances", obj_text_input);

    with (inst)
    {
        image_xscale = _xscale;
        image_yscale = 1;

        scr_setup_text_input(_input_id, _group);
    }

    return inst;
}

function create_code_box_input(_input_id, _x, _y, _xscale, _yscale, _group)
{
    var inst = instance_create_layer(_x, _y, "Instances", obj_text_input);

    with (inst)
    {
        image_xscale = _xscale;
        image_yscale = _yscale;

        scr_setup_text_input(_input_id, string(_group));
    }

    return inst;
	
}

// Hitbox type dropdown
// ID 0
var text_y = panel_y + 97;

create_panel_input(
    0,
    panel_x + string_length(input_labels.hit[0]) * 11,
    text_y,
    7,
	"hitbox"
);

// X / Y
// IDs 1 and 2

text_y += 35;

create_panel_input(1, panel_x + 160, text_y, 2.5,
		"hitbox");
create_panel_input(2, panel_x + 260, text_y, 2.5,
		"hitbox");

// X Scale / Y Scale
// IDs 3 and 4
text_y += 35;

create_panel_input(3, panel_x + 160, text_y, 2.5,
		"hitbox");
create_panel_input(4, panel_x + 260, text_y, 2.5,
		"hitbox");

// Other hitbox properties
// IDs 5 through 12


for (var i = 5; i <= array_length(input_labels.hit) - 1; i++)
{
    text_y = panel_y + 65 + i * 35;

    create_panel_input(
        i,
        panel_x + 180,
        text_y,
        5,
		"hitbox"
    );
}

text_y = panel_y + 97;

create_panel_input(
    100,
    panel_x + string_length(input_labels.anim[1]) * 11,
    text_y,
    2,
	"frame"
);
text_y += 35;
	
create_panel_input(
    101,
    panel_x + string_length(input_labels.anim[1]) * 11,
    text_y,
    2,
	"frame"
);

text_y = panel_y + 97;

/*create_code_box_input(
    200,
    panel_x + 30,
    panel_y + 420,
    9.25,
    5,
    "flag"
);

create_panel_input(
    201,
    panel_x + 30,
    text_y,
    8,
	"flag"
);*/
scr_hide_all_text_input_groups()