# First Game

A small Godot 4 game where the player collects medicinal herbs and returns them to an NPC.

## Play

Open `project.godot` in Godot 4.7.x and press **F6** on `main.tscn`, or **F5** to run the project. Tested with Godot 4.7.2. No external assets, plugins, or packages are required.

## Controls

- WASD / Arrow Keys — Move
- E — Interact / advance dialogue
- R — Restart after completion
- Esc — Exit after completion

The completion screen also has Restart and Exit buttons.

## Objective

Talk to the yellow herbalist at camp, finish the conversation, and collect five medicinal herbs in the forest. Approach a bright green herb and press E to collect it. Nine herbs are placed around the fixed map; trees, rocks, the pond, and map edges block movement. Once you have at least five, return to the herbalist and finish the conversation to deliver them and complete the quest.

Blue is the player; yellow is the NPC. Nearby interaction targets have a gold ring and a prompt. Dialogue pauses movement. Restart restores the initial position, quest state, and all herbs. Progress is not saved when the game exits.

## Engine

Godot 4.7.x, GDScript, 2D, Compatibility renderer. The reference viewport is 1280×720. The camera follows the player across a 2400×1600 map. Graphics use built-in drawing and UI nodes; there is no sound in this MVP.

## Project structure

- `main.tscn`, `main.gd` — Assemble the world and manage quest/dialogue state.
- `scripts/player.gd` — Normalized movement, collision, and camera.
- `scripts/world.gd` — Fixed camp/forest scenery and static collision bodies.
- `scripts/interaction_target.gd` — NPC and herb visuals and interaction data.
- `scripts/game_ui.gd` — Objective, herb count, prompts, dialogue, completion controls.
- `tests/test_game.gd` — Headless integration checks using real movement/physics and the game's interaction input handler.

## Validation

From the project directory, replace `godot` with your Godot 4.7.x executable if needed:

```sh
godot --headless --path . --editor --import
godot --headless --path . --quit-after 60
godot --headless --path . --script res://tests/test_game.gd
```

The test prints its check count and returns a nonzero exit code on failed checks. It covers quest acceptance, dialogue, actual movement and normalized speed, collision with scenery and boundaries, collection, duplicate prevention, UI counts, NPC delivery, and scene restart. Inspect Godot output for script errors too: some engine errors do not cause a nonzero exit code.

For a manual check, play from camp through completion, confirm prompts and text are readable, and try both the completion buttons and keyboard shortcuts. Full human playtime and PC display/input behavior require a graphical playtest; they are not measured by the headless tests.
