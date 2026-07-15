// obj_text_input Create Event

if (!variable_global_exists("text_input_focused"))
{
    global.text_input_focused = false;
}

if (!variable_global_exists("text_input_id"))
{
    global.text_input_id = undefined;
}

if (!variable_global_exists("text_input_instance"))
{
    global.text_input_instance = noone;
}
mx = 0
my = 0
highlighted = false;

attatched_id = -1;

numbers_only = false;
text_input_type = "input";

current_input = "";
current_list = [];

open_for = 0;
ignore_check = false;

text_input_ready = false;
text_input_undo_active = false;
text_input_undo_id = -1;
text_input_undo_target = undefined;
text_input_undo_before = undefined;
text_input_undo_property = "";

input_group = "default";
input_enabled = true;
text_input_ready = false;