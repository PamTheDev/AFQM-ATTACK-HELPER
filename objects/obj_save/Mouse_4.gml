if (variable_global_exists("context_click_consumed") && global.context_click_consumed) exit;

if (variable_global_exists("phase_check_window_open") && global.phase_check_window_open) exit;

scr_save_current_attack_json();

scr_run_json_to_gml_converter(
    global.current_attack_json_path,
    global.selected_gml_path
);
