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
  - S: Exports the current attack in the editor.
  - Z: Undoes the most recent action.
  - Y: Redoes the most recent undo.

## Mod Folder Select Menu
<img width="1367" height="767" alt="image" src="https://github.com/user-attachments/assets/7398f857-fa38-4ce9-a240-589270fc5bf2" />

This menu alows you to select a mod folder and to "Quick load" a mod. Once a mod is selected it combs through the folder converting any GIF files to sprite folders, identifying proper attacks, and caches all the information. 
This process usually takes around 5-20 seconds depending on how many gifs need converting, or how many attacks there are in total. Once a mod is loaded and cached it can be "Quick loaded". Quick loading a mod will not search for any new attack files, or attempt to convert any GIF files, it will only load the same attacks that were last loaded in the program.

## Context menu
<img width="213" height="207" alt="image" src="https://github.com/user-attachments/assets/f146ad5f-95e3-4191-a52e-f7c447f7ffaf" />

The context menu is accessed via right mouse click. This menu is, of course, context based, meaning only right-clicking some buttons or menus will create a context menu.

## Select Attack Menu
<img width="1296" height="711" alt="image" src="https://github.com/user-attachments/assets/ce8e1d6f-a9a6-4192-bf9c-081f4084a61f" />

The select menu is a list of attacks with two buttons on the bottom of the screen: New Attack and Edit.

- Attack Buttons
	- Attack buttons can be selected and must be selected in order for the 'Edit' button to function. They can also be double clicked or right-clicked to perform the same action as pressing the 'Edit' button.
- Edit Button
	- The 'Edit' button opens the main editor. An attack must be selected in order for the button to function.
- New Attack Button
	- The 'New Attack' button opens up a window that allows you to name a new attack, attach an animation, then go to the main editor to fill the new attack.
  - <img width="836" height="577" alt="image" src="https://github.com/user-attachments/assets/b9329ad9-44e4-4f04-aaa5-285bc62f6f33" />

# Editor Features
