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

if (variable_global_exists("context_active"))
{
    global.context_active = false;
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

// Hide every editor input while it is open
scr_hide_all_text_input_groups();

with (obj_text_input)
{
    input_enabled = false;
    visible = false;
    highlighted = false;
}

check_functions = scr_get_attack_connected_check_functions();
check_states = scr_get_phase_attack_connected_check_states(target_phase);
code_before = scr_get_phase_flags_code(target_phase);

column_count = 1;
row_count = ceil(array_length(check_functions) / column_count);
window_w = 900;
window_h = 650;
header_h = 72;
footer_h = 70;
option_h = 32;
option_gap_x = 20;
option_w = (window_w - 60 - option_gap_x) / column_count;
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
        scr_set_phase_attack_connected_checks(target_phase, check_states);

        var code_after = scr_get_phase_flags_code(target_phase);

        if (code_before != code_after)
        {
            if (!variable_global_exists("undo_history"))
            {
                global.undo_history = [];
            }

            array_push(global.undo_history, {
                type: "phase_attack_connected_checks",
                property: "flags",
                target: target_phase,
                before: code_before,
                after: code_after
            });

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
