// Logic smoke checks use the GML sources with a small GameMaker API shim.
// UI rendering and runner compilation still require GameMaker.
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const sandbox = {};
Object.assign(sandbox, {
global: { current_attack_data: { name: 'context_test', sprite: 'test' }, current_timeline_frame: 0 },
buffer_fixed: 0, buffer_text: 0, noone: -1,
"array_length":a=>a.length,
"array_push":(a,x)=>a.push(x),
"array_delete":(a,i,n)=>a.splice(i,n),
"array_insert":(a,i,x)=>a.splice(i,0,x),
"is_undefined":x=>x===undefined,
"is_array":Array.isArray,
"is_string":x=>typeof x==='string',
"is_struct":x=>x!==null&&typeof x==='object',
"variable_struct_exists":(o,k)=>Object.hasOwn(o,k),
"variable_struct_get_names":Object.keys,
"variable_struct_remove":(o,k)=>delete o[k],
"variable_clone":structuredClone,
"max":Math.max,
"min":Math.min,
"round":Math.round,
"clamp":(x,a,b)=>Math.max(a,Math.min(b,x)),
"string":String,
"real":Number,
"variable_global_exists":k=>Object.hasOwn(sandbox.global,k),
"show_debug_message":()=>{},
"scr_sort_all_timeline_tracks":()=>{},
"scr_recalculate_timeline_total_frames":()=>{},
"scr_clear_hitbox_selection":()=>{},
"scr_clear_animation_selection":()=>{},
"scr_show_only_text_input_group":()=>{},
"scr_save_current_attack_json":()=>{},
"mark_attack_json_dirty":()=>{},
"string_byte_length":s=>s.length,
"json_stringify":JSON.stringify,
"buffer_create":()=>0,
"buffer_write":(_,__,text)=>{sandbox.saved=JSON.parse(text)},
"buffer_save":()=>{},
"buffer_delete":()=>{},
"method":(o,f)=>f.bind(o),
method_get_self: () => undefined
});
vm.createContext(sandbox);
const transform = s => s.replaceAll('[$ ', '[').replace(/with \(obj_timeline\) \{[^}]*\}/g, '');
const source = p => fs.readFileSync(path.join(root, p), 'utf8');
for (const p of [
'scripts/context_menu_tools/context_menu_tools.gml',
'scripts/phase_tools/phase_tools.gml',
'scripts/scr_get_or_create_json_frame/scr_get_or_create_json_frame.gml',
'scripts/scr_save_attack_json_from_timeline/scr_save_attack_json_from_timeline.gml',
'scripts/scr_build_timeline_from_attack/scr_build_timeline_from_attack.gml',
'scripts/scr_undo_last_action/scr_undo_last_action.gml'])
vm.runInContext(transform(source(p)), sandbox);
const phase = (start, duration, extend = false) => ({ start, duration, lasts: duration - 1, flags: [], extend, attack_stop_state: 'none' });
const hb = { hitboxCreateFunction: 'hitbox_create_melee', lasts: 1, group: 0 };
const key = { start: 5, duration: 1, hitbox: hb };
sandbox.global.timeline = { total_frames: 9, phases: [phase(0, 2), phase(2, 3, true), phase(5, 4)], tracks: [
{type: 'animation', name: 'Animation', keys: []},
{type: 'hitbox', name: 'Hitbox 1', keys: [key]},
{type: 'flag', name: 'Flag 1', keys: []}
]};
sandbox.scr_save_attack_json_from_timeline(sandbox.global.timeline, 'test.json');
const fixture = sandbox.saved;
assert.equal(fixture.phases.length, 2);
assert.equal(fixture.phases[1].lasts, '6');
assert.equal(fixture.phases[1].extensionBaseLasts, 3);
assert.equal(fixture.phases[1].extensionFrames, 3);
assert.equal(fixture.phases[1].frames[0].frame, 3);
const reloaded = sandbox.scr_build_timeline_from_attack(fixture);
assert.equal(reloaded.phases.length, 3);
assert.equal(reloaded.phases[1].extend, true);
assert.equal(reloaded.tracks[2].keys.length, 0);
const before = sandbox.scr_context_capture_timeline();
sandbox.scr_context_edit(() => { hb.hitboxCreateFunction = 'hitbox_create_grab'; sandbox.global.timeline.tracks.splice(2, 1); });
sandbox.scr_undo_last_action();
assert.equal(hb.hitboxCreateFunction, 'hitbox_create_melee');
assert.equal(sandbox.global.timeline.tracks.length, 3);
assert.equal(sandbox.global.timeline.tracks[1].keys[0], key);
sandbox.scr_redo_last_action();
assert.equal(hb.hitboxCreateFunction, 'hitbox_create_grab');
assert.equal(sandbox.global.timeline.tracks.length, 2);
sandbox.scr_undo_last_action();
sandbox.scr_context_edit(() => { hb.hitboxCreateFunction = 'hitbox_create_windbox'; });
assert.equal(sandbox.global.redo_history.length, 0);
sandbox.scr_context_restore_timeline(before);
const oldNextStart = sandbox.global.timeline.phases[1].start;
sandbox.scr_context_edit(() => { sandbox.scr_timeline_add_phase_after(sandbox.global.timeline, 0); });
assert.equal(sandbox.global.timeline.phases[1].duration, 4);
assert.equal(sandbox.global.timeline.phases[1].lasts, 3);
assert.equal(sandbox.global.timeline.phases[2].start, oldNextStart + 4);
sandbox.scr_undo_last_action();
assert.equal(sandbox.global.timeline.phases.length, 3);
sandbox.scr_redo_last_action();
assert.equal(sandbox.global.timeline.phases[1].duration, 4);
sandbox.scr_context_restore_timeline(before);

Object.assign(sandbox, {
id: 1, instance_exists: () => true, instance_find: () => 1,
display_get_gui_width: () => 800, display_get_gui_height: () => 600,
device_mouse_x_to_gui: () => sandbox.mx, device_mouse_y_to_gui: () => sandbox.my,
point_in_rectangle: (x,y,l,t,r,b) => x >= l && x <= r && y >= t && y <= b,
mouse_check_button_pressed: () => sandbox.click,
keyboard_check_pressed: () => false, string_width: s => s.length * 8,
mb_left: 0, mb_right: 1, vk_escape: 27
});
vm.runInContext(transform(source('objects/obj_context_menu/Create_0.gml')), sandbox);
const child = sandbox.scr_context_menu_input('Melee', 1, () => { sandbox.chosen = true; });
const parent = sandbox.scr_context_menu_input('Change type >', 1, () => {});
parent.children = [child];
sandbox.global.context_items = [parent]; sandbox.global.context_active = true;
sandbox.global.context_owner = 1; sandbox.global.context_x = 750; sandbox.global.context_y = 590;
sandbox.refresh_layout();
assert(sandbox.global.context_x + sandbox.menu_w <= 800);
assert(sandbox.global.context_y + sandbox.menu_height <= 600);
sandbox.mx = sandbox.global.context_x + 10; sandbox.my = sandbox.global.context_y + 10; sandbox.click = false;
const menuStep = transform(source('objects/obj_context_menu/Step_0.gml')).replace(/\bexit;/g, 'return;');
vm.runInContext('(function(){' + menuStep + '})()', sandbox);
assert.equal(sandbox.global.context_submenu, 0);
sandbox.refresh_layout();
assert.equal(sandbox.menu_panels.length, 2);
const panel = sandbox.menu_panels[1];
assert(panel.x >= 0 && panel.x + sandbox.menu_w <= 800);
sandbox.mx = panel.x + 10; sandbox.my = panel.y + 10; sandbox.click = true;
vm.runInContext('(function(){' + menuStep + '})()', sandbox);
assert.equal(sandbox.chosen, true);
assert.equal(sandbox.global.context_active, false);

const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'afqm-context-'));
try {
const jsonPath = path.join(temp, 'fixture.json'), gmlPath = path.join(temp, 'fixture.gml'), parsedPath = path.join(temp, 'parsed.json');
fs.writeFileSync(jsonPath, JSON.stringify(fixture));
execFileSync(path.join(root, 'datafiles/tools/JsonToGmlConverter.exe'), [jsonPath, gmlPath]);
const gml = fs.readFileSync(gmlPath, 'utf8');
assert.doesNotMatch(gml, /_extend_phase_connected/);
assert.match(gml, /attack_frame = attack_connected\(\) \? 6 : 3;/);
execFileSync(path.join(root, 'datafiles/tools/AttackParser.exe'), [gmlPath, parsedPath]);
assert.deepEqual(JSON.parse(fs.readFileSync(parsedPath, 'utf8')), fixture);
fs.appendFileSync(gmlPath, '\n// External edit\n');
execFileSync(path.join(root, 'datafiles/tools/AttackParser.exe'), [gmlPath, parsedPath]);
const external = JSON.parse(fs.readFileSync(parsedPath, 'utf8'));
assert.equal(external.editorTimeline, undefined);
assert.equal(external.phases[1].lasts, '6');
} finally {
for (const name of fs.readdirSync(temp)) fs.unlinkSync(path.join(temp, name));
fs.rmdirSync(temp);
}
console.log('Passed: extension timing, persistence, undo/redo, submenu hit areas, converter roundtrip, and external edits.');
