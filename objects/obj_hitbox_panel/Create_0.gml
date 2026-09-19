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
    "sfx:",
    "Group:"
	],
	anim :[
	"On Frame:",
	"Animation Frame:"
	]
};



// Helper for creating a text input


function create_panel_input(_input_id, _x, _y, _xscale, _group, _flag_type_key = "")
{
    var inst = instance_create_layer(_x, _y, "Instances", obj_text_input);

    with (inst)
    {
        image_xscale = _xscale;
        image_yscale = 1;
        flag_type_key = _flag_type_key;

        scr_setup_text_input(_input_id, _group);
    }

    return inst;
}

function create_code_box_input(_input_id, _x, _y, _xscale, _yscale, _group, _flag_type_key = "")
{
    var inst = instance_create_layer(_x, _y, "Instances", obj_text_input);

    with (inst)
    {
        image_xscale = _xscale;
        image_yscale = _yscale;
        flag_type_key = _flag_type_key;

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
// IDs 5 through 13


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

// Flag type selector. global.flag_type_submenu_open controls which definition's
// inputs are visible while this dropdown remains available for every flag type.
if (!variable_global_exists("flag_type_submenu_open"))
{
    global.flag_type_submenu_open = "custom_code";
}

create_panel_input(
    201,
    panel_x + 115,
    panel_y + 97,
    6.5,
    "flag"
);

// Create every flag submenu from the central definition list. Regular inputs
// flow down the panel automatically; code boxes keep the existing large editor.
var flag_definitions = scr_get_flag_type_definitions();

for (var flag_type_index = 0; flag_type_index < array_length(flag_definitions); flag_type_index++)
{
    var flag_definition = flag_definitions[flag_type_index];

    for (var flag_input_index = 0; flag_input_index < array_length(flag_definition.inputs); flag_input_index++)
    {
        var flag_input = flag_definition.inputs[flag_input_index];

        if (flag_input.input_type == "codebox")
        {
            create_code_box_input(
                flag_input.id,
                panel_x + 30,
                panel_y + 420,
                9.25,
                5,
                "flag",
                flag_definition.key
            );
        }
        else
        {
            create_panel_input(
                flag_input.id,
                panel_x + 180,
                panel_y + 155 + flag_input_index * 40,
                5.5,
                "flag",
                flag_definition.key
            );
        }
    }
}

// Phase code uses the same temporary code-box editor as frame flags.
create_code_box_input(
    300,
    panel_x + 30,
    panel_y + 420,
    9.25,
    5,
    "phase"
);
scr_hide_all_text_input_groups()
