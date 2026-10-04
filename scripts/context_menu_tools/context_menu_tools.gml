function scr_context_menu_init()
{
    if (variable_global_exists("context_definitions")) return;
    global.context_definitions = {};
    global.context_active = false;
    global.context_click_consumed = false;
    global.context_menu = "";
    global.context_items = [];
    global.context_owner = noone;
    global.context_x = 0;
    global.context_y = 0;
}

// "function" is a GML keyword; this helper stores that exact field safely.
function scr_context_menu_input(_label, _section, _action, _dependence = undefined)
{
    var entry = { label: _label, section: _section };
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
function scr_context_menu_open(_key, _owner = id)
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
    global.context_items = definition.inputs;
    global.context_owner = _owner;
    global.context_x = device_mouse_x_to_gui(0);
    global.context_y = device_mouse_y_to_gui(0);
    global.context_active = array_length(global.context_items) > 0;
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
