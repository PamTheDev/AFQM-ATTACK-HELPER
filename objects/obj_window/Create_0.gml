if (instance_number(obj_window) > 1)
{
    instance_destroy();
    exit;
}

global.phase_check_window_open = true;

if (variable_global_exists("context_active"))
{
    global.context_active = false;
}

window_mode = "attack_connected";

if (variable_global_exists("phase_window_mode"))
{
    window_mode = global.phase_window_mode;
}

target_phase = undefined;
target_phase_index = -1;

if (variable_global_exists("phase_check_target_phase"))
{
    target_phase = global.phase_check_target_phase;
}

if (variable_global_exists("phase_check_target_phase_index"))
{
    target_phase_index = global.phase_check_target_phase_index;
}

if (is_undefined(target_phase))
{
    target_phase = scr_get_selected_phase();
    target_phase_index = global.selected_phase_index;
}

if (is_undefined(target_phase))
{
    global.phase_check_window_open = false;
    instance_destroy();
    exit;
}

// Hide every editor input while this modal window is open.
scr_hide_all_text_input_groups();

with (obj_text_input)
{
    input_enabled = false;
    visible = false;
    highlighted = false;
}

option_labels = [];
check_states = [];
selected_state_index = 0;
state_before = "none";
code_before = "";

if (window_mode == "attack_stop")
{
    option_labels = scr_get_phase_attack_stop_states();
    state_before = scr_get_phase_attack_stop_state(target_phase);

    for (var state_index = 0; state_index < array_length(option_labels); state_index++)
    {
        if (option_labels[state_index] == state_before)
        {
            selected_state_index = state_index;
            break;
        }
    }

    column_count = 3;
}
else
{
    option_labels = scr_get_attack_connected_check_functions();
    check_states = scr_get_phase_attack_connected_check_states(target_phase);
    code_before = scr_get_phase_flags_code(target_phase);
    column_count = 1;
}

row_count = ceil(array_length(option_labels) / column_count);
window_w = 900;
window_h = 650;
header_h = 72;
footer_h = 70;
option_h = window_mode == "attack_stop" ? 26 : 32;
option_gap_x = 20;
option_w = (window_w - 40 - option_gap_x * (column_count - 1)) / column_count;
checkbox_size = 18;

window_x = (display_get_gui_width() - window_w) * 0.5;
window_y = (display_get_gui_height() - window_h) * 0.5;

open_delay = 1;
closing = false;

close_and_apply = function()
{ 
    if (closing) return;
    closing = true;

    if (!is_undefined(target_phase))
    {
        var value_changed = false;

        if (window_mode == "attack_stop")
        {
            var state_after = option_labels[selected_state_index];
            scr_set_phase_attack_stop_state(target_phase, state_after);
            value_changed = state_before != state_after;

            if (value_changed)
            {
                if (!variable_global_exists("undo_history"))
                {
                    global.undo_history = [];
                }

                global.redo_history = [];
        array_push(global.undo_history, {
                    type: "phase_attack_stop_state",
                    property: "attack_stop_state",
                    target: target_phase,
                    before: state_before,
                    after: state_after
                });
            }
        }
        else
        {
            scr_set_phase_attack_connected_checks(target_phase, check_states);

            var code_after = scr_get_phase_flags_code(target_phase);
            value_changed = code_before != code_after;

            if (value_changed)
            {
                if (!variable_global_exists("undo_history"))
                {
                    global.undo_history = [];
                }

                global.redo_history = [];
        array_push(global.undo_history, {
                    type: "phase_attack_connected_checks",
                    property: "flags",
                    target: target_phase,
                    before: code_before,
                    after: code_after
                });
            }
        }

        if (value_changed)
        {
            mark_attack_json_dirty();
            scr_save_current_attack_json();
        }

        if (global.selected_phase_index == target_phase_index)
        {
            scr_show_only_text_input_group("phase");
            scr_refresh_text_input_group("phase");
        }
    }

    instance_destroy();
};
