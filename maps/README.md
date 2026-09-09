# Editing Act I maps

The table now reads geometry and encounter data from Godot scenes instead of
hard-coded coordinate arrays in `main.gd`.

## Shared layout geometry

Open a scene under `maps/layouts/` to change every room that uses that layout:

- `classic_layout.tscn` — classic upper banks and the shared cabinet
- `ring_layout.tscn` — Ring Corridor walls and openings
- `mechanism_layout.tscn` — Mechanism Hall banks
- `rail_vault_layout.tscn` — three persistent drop targets guarding a raised rail
- `open_layout.tscn` — shared outer walls, slingshots, combat runes and Fury skills

Select a wall node and use the 2D move, rotate or scale tools. Its `End Offset`,
`Friction` and `Kick` values remain available in the Inspector.

## Individual rooms

Open a scene under `maps/rooms/` to move enemies and room-specific objects.
Enemy nodes expose kind, radius, base HP, objective status and Boss guard slot.
Room 1-2 owns its three-node target gate, room 1-4 owns its diamond, and rooms
1-7 and 1-8 own their rotor nodes. Each drop target exposes its group, size,
hit count and rebound. The unused Rail Vault template remains available for a
future room; its `Line2D` route is directly editable in the 2D view.

Rails preserve the speed captured at their entrance and only redirect the ball
along their authored route. A non-empty rail `Lock Group` opens when every drop
target in the matching `Group Id` is down. Drop targets persist across drains
and reset only when a new room is loaded.

The runtime still uses the existing custom pinball collision and drawing code.
The scene nodes are converted to that runtime data when each room begins, which
keeps the established physics behaviour while making layout work visual.

To launch one room directly while iterating, pass `--room-preview=N` after the
Godot separator, for example: `godot --path . -- --room-preview=5`.
