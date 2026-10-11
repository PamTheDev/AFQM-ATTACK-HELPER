# AFQM ATTACK HELPER
Attack editor for AFQM and other PFE games

Right-click phase brackets for Delete Phase and the Extend phase toggle. Extension
segments between phases add their duration to the following runtime phase when
the preceding phase connects. Consecutive extension segments add together.
Right-click layer headers for new flag/hitbox layers and Delete layer; the
Animation layer is retained. Right-click a flag or hitbox key (or a preview
hitbox) and hover Change type to open the side submenu.

Undo, Redo, and Play/Stop appear in every context menu while an attack is open.
Ctrl+Z undoes an edit and Ctrl+Shift+Z redoes it. Saved GML carries verified editor
metadata so reopening retains extension segments and empty layers. External GML
edits invalidate that metadata and use the normal parser.

Run the logic and converter smoke checks with node verification/context-menu-smoke.cjs.
The checks use a small engine API shim; visual verification requires GameMaker.
