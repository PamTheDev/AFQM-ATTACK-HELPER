if (variable_global_exists("context_click_consumed") && global.context_click_consumed) exit;

if (variable_global_exists("phase_check_window_open") && global.phase_check_window_open) exit;

scr_context_menu_set_definition({ key: "export_format", inputs: [
    scr_context_menu_input("Export UMT", 0, function()
    {
        if (!scr_save_current_attack_json()) return;
        scr_run_json_to_gml_converter(global.current_attack_json_path, global.selected_gml_path, "UMT");
    }),
    scr_context_menu_input("Export Workshop", 0, function()
    {
        if (!scr_save_current_attack_json()) return;
        scr_run_json_to_gml_converter(global.current_attack_json_path, global.selected_gml_path, "Workshop");
    }),
    scr_context_menu_input("Cancel", 1, function() {})
] });
scr_context_menu_open("export_format", id, false, true);
