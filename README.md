# AFQM ATTACK HELPER
Attack editor for AFQM and other PFE games
## THIS PROGRAM IS STILL IN ALPHA
Some menus may not fully work as intended, there may be some glitches in rendering, there may even be some glitches in exporting, all things expected in an alpha launch. But, this is currently meant for use in testing the existing features, not for full development **CURRENTLY**.
## This is **NOT** a program that you can draw in.
The primary goal of this program is to lower the barrier of entry and make the coding experience a lot more beginner friendly rather than coding most aspects.
# Organization

Mods in the program's alpha are organized as the following:
- Root mod folder
  - Scripts
  - Sprites

<img width="572" height="298" alt="image" src="https://github.com/user-attachments/assets/d43cc6d2-df1c-4eb2-9782-90b17f346c9c" />


Scripts are where the gml files are located. Only scripts that are identified as attack scripts are detected.

Sprites are where all the characters sprites/ animations are stored. Each animation has its own folder named after the sprite (i.e. "spr_stick_dtilt"); Inside of each folder is an image file for each frame of animation with two naming conventions: name + _frame # (i.e. "spr_stick_dtilt_0.png" for the first frame), and 000 + frame # (i.e. "0000.png" for the first frame). Since they are stored very specifically, there are 2 methods to storing them correctly.

## 1. Automatically through GIFs
The program automatically re-formats any GIF files into the proper format for the program to use in the 000# naming convention. This is the recommended method when utilizing the program.

## 2. Manually
You can of course manually export each sprite 1 by 1 if that is what you want to do, as long as the sprites are named correctly there will be no issues in the program.

# Program Features
This section explains the function of the features that exist in the program as a whole, the next section explains the function of the _editor_ itself.
## Keybinds
Below is a list of keybinds featured in the program:
- Ctrl +...
  - Z: Undoes the most recent action.
  - Shift + Z: Redoes the most recent undo.
- N: Adds a phase after the selected phase.
- M: Merges the selected phase with the next phase.

To export the current attack, use the Save button in the editor. Undo and Redo are also available through the editor's context menus.

## Mod Folder Select Menu
<img width="1367" height="767" alt="image" src="https://github.com/user-attachments/assets/7398f857-fa38-4ce9-a240-589270fc5bf2" />

This menu alows you to select a mod folder and to "Quick load" a mod. Once a mod is selected it combs through the folder converting any GIF files to sprite folders, identifying proper attacks, and caches all the information.
This process usually takes around 5-20 seconds depending on how many gifs need converting, or how many attacks there are in total. Once a mod is loaded and cached it can be "Quick loaded". Quick loading a mod will not search for any new attack files, or attempt to convert any GIF files, it will only load the same attacks that were last loaded in the program.

### Context menu
<img width="213" height="207" alt="image" src="https://github.com/user-attachments/assets/f146ad5f-95e3-4191-a52e-f7c447f7ffaf" />

The context menu is accessed via right mouse click. This menu is, of course, context based, meaning only right-clicking some buttons or menus will create a context menu.

## Select Attack Menu
<img width="1296" height="711" alt="image" src="https://github.com/user-attachments/assets/ce8e1d6f-a9a6-4192-bf9c-081f4084a61f" />

The select menu is a list of attacks with two buttons on the bottom of the screen: New Attack and Edit.

- Attack Buttons
	- Attack buttons can be selected and must be selected in order for the Edit button to function. They can also be double clicked or right-clicked to perform the same action as pressing the Edit button.
- Edit Button
	- The Edit button opens the main editor. An attack must be selected in order for the button to function.
- New Attack Button
	- The 'New Attack' button opens up a window that allows you to name a new attack, attach an animation, then go to the main editor to fill the new attack.
  - <img width="836" height="577" alt="image" src="https://github.com/user-attachments/assets/b9329ad9-44e4-4f04-aaa5-285bc62f6f33" />

# Editor Features
This section explains the features within the main editor.
<img width="1365" height="767" alt="image" src="https://github.com/user-attachments/assets/2642e4a6-8b96-4418-9c94-a682490fef95" />

### Display window
This is where the sprite for the attack is displayed, along with any other info such as any necessary flags and hitboxes.

Use the mouse wheel over the Display window to zoom in or out. Hold the middle mouse button and drag to move the view. Clicking an existing hitbox selects it for editing; you can drag it to change its position or use its resize handles to change its size.
### Hitbox selector
These are the buttons for adding hitboxes to the attack. Selecting one will make it so that the next mouse click on the Display window will add the hitbox and allow for stretching of the hitbox.


## Editor Timeline

The editor timeline hosts a handful of features so this section will describe them.
<img width="986" height="226" alt="image" src="https://github.com/user-attachments/assets/60a05d07-0e35-4e87-bfd4-f96e25aa46c0" />

### Playhead and Header
The playhead is the arrow and green line on the timeline. It shows the current frame that the attack is on. You can click anywhere on the timeline to move the playhead to that frame.

The header is above all the tracks and labels the frame numbers. Clicking and dragging the header will move the playhead to that position.

### Keys and Tracks
There are three types of tracks: animation, hitbox, and flag tracks. Each track contains keys that tell the attack what to do at a certain frame. The position of a key is when it starts, and the width of a hitbox key is how long the hitbox lasts.

- Animation keys set which sprite frame is displayed. The animation frame stays displayed until the next animation key changes it.
- Hitbox keys set when a hitbox appears and how long it is active. Separate hitbox tracks allow multiple hitboxes to be active at the same time.
- Flag keys contain code or an action that happens on a specific frame. Multiple flag tracks allow more than one flag at the same frame.

Click a key to select it and show its properties in the Edit Panel. Drag a key left or right to change when it starts. Drag the right edge of a hitbox key to change its duration. Hitbox and flag keys can also be moved between tracks of the same type.

Right-click a track to access layer options, such as adding a flag or hitbox layer, or deleting a layer. Right-click a hitbox or flag key to change its type.

Hold Shift and use the mouse wheel over the timeline to scroll horizontally. Hold Ctrl and use the mouse wheel to zoom the timeline in or out.

### Phase Tags
Phase tags are above the frame numbers and divide the attack into sections. These can be used to separate parts of an attack, such as startup, the active part of the attack, and recovery.

Click a phase tag to select it and show its code in the Edit Panel. Drag a phase boundary to change its duration. Right-click a phase to insert or delete a phase, or toggle the Extend phase option. N adds a phase after the selected phase, and M merges the selected phase with the next one.

## Editor Features Cont.
### Play/Pause and Next/Previous frame buttons
Above the timeline are the Play/Pause and Next/Previous frame buttons. Play advances the preview through the attack and loops back to the beginning when it reaches the end. Pause stops it on the current frame. The Next and Previous buttons move the playhead one frame at a time, which is useful for checking animation changes and hitbox timing.

The preview helps you check the animation and hitboxes. Test the exported attack in the game as well to check how its code behaves during gameplay.

### New Animation and Flag key buttons
These buttons add a key at the current playhead position. The animation button adds an animation key, and the flag button adds a flag key. Select the new key to fill in its properties through the Edit Panel.

An animation key starts with animation frame 0. A new flag starts as custom code, so you can write the code yourself or choose one of the available flag types.

## Edit Panel
The Edit Panel changes depending on what you select. If you want to edit a hitbox, animation key, flag, or phase, select it first.

- Hitboxes
  - Change the hitbox type, X and Y position, X and Y scale, damage, base knockback, knockback scale, hitlag, angle, duration, vfxStyle, sfx, and group.
- Animation keys
  - Change the frame of the attack that the key is on and the sprite's animation frame. These are separate values: the attack frame is when the change happens, while the animation frame is which image gets displayed.
- Flags
  - Choose the flag type and fill in the fields for that action. Custom code allows you to enter GML directly. Available types include actions for effects, sounds, speed changes, and resetting hitbox groups.
- Phases
  - Edit the code belonging to the selected phase through its code box.

Frame numbers start at 0, so animation frame 0 is the first image in the sprite folder.

## Saving and Exporting
The editor saves its timeline changes to an intermediate JSON file. To write those changes back to the attack's GML script, click the Save button. Saving the editor's JSON and exporting the GML are separate steps, so make sure to export before testing the updated attack in the game.

Exporting writes to the selected attack script. Since this program is still in alpha, keep a copy of your mod before exporting and check the resulting attack in-game.

## Getting Started
1. Put your attack scripts and sprites in the mod folder structure described above.
2. Select the root mod folder from the Mod Folder Select Menu and wait for it to finish loading.
3. Select an attack and press Edit, or use New Attack to create one and attach its animation.
4. Move the playhead to the frame you want to edit, then add or select the animation keys, hitboxes, and flags you need.
5. Fill in their properties in the Edit Panel and use the preview to check the timing.
6. Click Save to export the attack, then test it in the game.

## Common Issues
- A new attack or GIF does not appear after Quick loading: Select the mod folder again through the regular folder select option. Quick loading uses the previous cache and does not scan for new files.
- An animation does not load correctly: Check that it has its own sprite folder and that its PNG frames use one of the naming conventions described above, starting at frame 0.
- An attack does not appear in the select menu: Check that its GML file is in the Scripts folder and is recognized as an attack script. The program does not list every GML script as an attack.
- Changes do not appear in-game: Make sure you exported with the Save button and are testing the updated GML script.
