function mark_attack_json_dirty()
{
    global.attack_json_dirty = true;
    if (!(variable_global_exists("history_restoring") && global.history_restoring)) global.redo_history = [];
}