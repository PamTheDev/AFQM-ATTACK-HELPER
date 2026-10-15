function scr_context_menu_init()
{
    if (variable_global_exists("context_definitions")) return;
    global.context_definitions = {};
    global.context_active = false;
    global.context_click_consumed = false;
    global.context_menu = "";
    global.context_items = [];
    global.context_submenu = -1;
    global.context_owner = noone;
    global.context_x = 0;
    global.context_y = 0;
}

// "function" is a GML keyword; this helper stores that exact field safely.
function scr_context_menu_input(_label, _section, _action, _dependence = undefined)
{
    var entry = { label: _label, section: _section, bound_action: is_struct(method_get_self(_action)) };
    entry[$ "function"] = _action;
    if (!is_undefined(_dependence)) entry.dependence = _dependence;
    return entry;
}

// Register or replace { key: "layer", inputs: [...] } from the owning object.
// Input order is preserved; a section change adds a separator.
function scr_context_menu_set_definition(_definition)
{
    scr_context_menu_init();
    global.context_definitions[$ _definition.key] = _definition;
    if (global.context_active && global.context_menu == _definition.key)
    {
        global.context_items = _definition.inputs;
        if (array_length(global.context_items) == 0) scr_context_menu_close();
    }
}

// The clicked object chooses the key, just like menu_focus. Both callbacks
// run with self bound to _owner and take no arguments.
function scr_context_menu_open(_key, _owner = id, _include_history = true, _ignore_opening_click = false)
{
    scr_context_menu_init();
    if (!instance_exists(_owner)) return false;
    if (!variable_struct_exists(global.context_definitions, _key))
    {
        scr_context_menu_close();
        return false;
    }
    var definition = global.context_definitions[$ _key];
    global.context_menu = _key;
    global.context_items = scr_context_copy_array(definition.inputs);
    if (_include_history && variable_global_exists("timeline") && !is_undefined(global.timeline))
    {
        array_push(global.context_items, scr_context_menu_input("Undo", 99, function() { scr_undo_last_action(); }, function() { return variable_global_exists("undo_history") && array_length(global.undo_history) > 0; }));
        array_push(global.context_items, scr_context_menu_input("Redo", 99, function() { scr_redo_last_action(); }, function() { return variable_global_exists("redo_history") && array_length(global.redo_history) > 0; }));
        array_push(global.context_items, scr_context_menu_input(global.playing_animation ? "Stop" : "Play", 99, function() { global.playing_animation = !global.playing_animation; }));
    }
    global.context_owner = _owner;
    global.context_submenu = -1;
    global.context_x = device_mouse_x_to_gui(0);
    global.context_y = device_mouse_y_to_gui(0);
    global.context_active = array_length(global.context_items) > 0;
    global.context_ignore_opening_click = _ignore_opening_click;
    return global.context_active;
}

function scr_context_menu_close()
{
    global.context_active = false;
    global.context_menu = "";
    global.context_items = [];
    global.context_owner = noone;
}

function scr_context_menu_input_enabled(_input)
{
    if (!instance_exists(global.context_owner)) return false;
    if (!variable_struct_exists(_input, "function")) return false;
    if (!variable_struct_exists(_input, "dependence")) return true;
    var check = _input.dependence;
    if (is_undefined(check)) return true;
    return method(global.context_owner, check)();
}

function scr_context_copy_array(_array)
{
    var result = [];
    for (var i = 0; i < array_length(_array); i++) array_push(result, _array[i]);
    return result;
}
// Shallow copies preserve live key references used by existing undo actions.
function scr_context_capture_timeline()
{
    var result = [];
    var targets = [global.timeline];
    for (var p = 0; p < array_length(global.timeline.phases); p++) array_push(targets, global.timeline.phases[p]);
    for (var t = 0; t < array_length(global.timeline.tracks); t++)
    {
        var track = global.timeline.tracks[t];
        array_push(targets, track);
        for (var k = 0; k < array_length(track.keys); k++)
        {
            var key = track.keys[k];
            array_push(targets, key);
            if (variable_struct_exists(key, "hitbox")) array_push(targets, key.hitbox);
            if (variable_struct_exists(key, "flag")) array_push(targets, key.flag);
        }
    }
    for (var i = 0; i < array_length(targets); i++)
    {
        var target = targets[i];
        var value = {};
        var names = variable_struct_get_names(target);
        for (var n = 0; n < array_length(names); n++)
        {
            var item = target[$ names[n]];
            value[$ names[n]] = is_array(item) ? scr_context_copy_array(item) : item;
        }
        array_push(result, { target: target, value: value });
    }
    return result;
}
function scr_context_restore_timeline(_state)
{
    for (var i = 0; i < array_length(_state); i++)
    {
        var target = _state[i].target;
        var names = variable_struct_get_names(target);
        for (var n = 0; n < array_length(names); n++) variable_struct_remove(target, names[n]);
        names = variable_struct_get_names(_state[i].value);
        for (var n = 0; n < array_length(names); n++)
        {
            var item = _state[i].value[$ names[n]];
            target[$ names[n]] = is_array(item) ? scr_context_copy_array(item) : item;
        }
    }
    scr_clear_hitbox_selection();
    scr_clear_animation_selection();
    global.selected_flag_key = undefined;
    global.selected_phase_index = -1;
    scr_show_only_text_input_group("default");
    with (obj_timeline) { selected_track = -1; selected_key = -1; }
    global.current_timeline_frame = clamp(global.current_timeline_frame, 0, max(0, global.timeline.total_frames - 1));
    mark_attack_json_dirty();
    scr_save_current_attack_json();
}
function scr_context_edit(_action)
{
    var before = scr_context_capture_timeline();
    _action();
    scr_timeline_refresh_phase_indices(global.timeline);
    scr_recalculate_timeline_total_frames(global.timeline);
    if (!variable_global_exists("undo_history")) global.undo_history = [];
    global.redo_history = [];
    array_push(global.undo_history, { type: "context_edit", before: before });
    mark_attack_json_dirty();
    scr_save_current_attack_json();
}
function scr_redo_last_action()
{
    if (!variable_global_exists("redo_history") || array_length(global.redo_history) == 0) return;
    var index = array_length(global.redo_history) - 1;
    var action = global.redo_history[index];
    array_delete(global.redo_history, index, 1);
    global.history_restoring = true;
    scr_context_restore_timeline(action.redo_state);
    global.history_restoring = false;
    array_push(global.undo_history, action);
}
function scr_context_type_action(_target, _type, _flag)
{
    return method({ target: _target, value: _type, flag: _flag }, function()
    {
        scr_context_edit(method(self, function()
        {
            if (flag)
            {
                scr_apply_flag_type(target, value);
                global.flag_type_submenu_open = value;
            }
            else target.hitboxCreateFunction = value;
        }));
        if (flag) scr_refresh_flag_type_submenu();
        scr_refresh_text_input_group(flag ? "flag" : "hitbox");
    });
}
