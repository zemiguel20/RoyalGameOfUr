# Project setup

This project uses Godot 4.2 . C# support is not required, but using the .NET version of the engine will still work just as fine.

The project contains models in FBX format, and thus the Godot Engine's FBX2glTF importer is needed.
The engine should automatically prompt to install and configure the importer, but if not, then go to `Editor -> Configure FBX Importer...`, which manually opens the corresponding  window.

# Folders

The following list describes the upper level folder of the project, which mainly organize files by type. Within these folders some files can be further organized by scope, but it is not a strict rule.
- `addons`: external plugins
- `animations`: animation data resources.
- `audio`: game sounds.
- `builds`: target folder when exporting the project.
- `docs`: technical documentation of the project.
- `materials`: all materials.
- `models`: all 3D model files.
- `physics_materials`: all physics materials.
- `resources`: custom resource files (e.g. rulesets).
- `scenes`: all scenes and prefabs.
- `scripts`: all code, mainly game scripts.
- `shaders`: all shaders
- `test`: isolated test scenes for whatever needs testing (e.g. dice rolling physics)
- `textures`: all textures used by materials and 3D models
- `ui`: contains fonts, sprites, and resources used within the game UI.

# Entities

## Die
The die is rolled with physics, so the root node type is `RigidBody3D`. Contains as component child nodes a `MeshHighlighter` to allow highlighting, a `SelectionInputReader` to read game input, and a `SimpleMovementAnimationPlayer` to move the die around without using physics.
There is also a `DieTip` node for each tip of the die. This node function has the normal vector of the tip (used to know which one is facing up) and has a roll value defined.

The `Die` type extends the root node providing the API to interact with the components of the die and implements the roll logic.

The scene file name is `d4_die.tscn`.

## Piece
The piece is a simple 3D object that is moved around. It contains a `MeshHighlighter` node to allow highlighting the piece model and a `SimpleMovementAnimationPlayer` node to allow moving the piece around the board.
The root node is a `Node3D` of type `Piece`. This script provides the API to move and highlight the piece.

It has a base scene `piece_base.tscn` with 2 variations `piece_black.tscn` and `piece_white.tscn`. These variations add the corresponding black and white materials. 

## Spot
The spot represents a place where pieces can be placed. Also, it is the selection target when choosing a move, since we move pieces *from* a spot *to* another spot. It contains a `SelectionInputReader` node that allows reading the input, and a `MeshHighlighter` node paired with an invisible mesh to allow highlighting the spot area.
The root node is a `Node3D` of type `Spot`, which provides an API to the input, highlight, and logic for placing pieces.

The scene file name is `spot.tscn`.

## Board
The board is a collection of spots placed accordingly in and around the board model. For each player, it has a set of spots that represent the starting zone, and a sequence of spots representing the track.
The root node is a `Node3D` of type `Board`. It has a set of lists exposed to the editor, so that the spots can be assigned as starting spots or as part of the track.

Each type of board has their own dedicated scene, where the track can be changed. So the Finkel board is in the `board_finkel.tscn` scene, and the Masters board is in the `board_masters.tscn` scene.

The `Board` spawns the pieces, allows queries to the state of the board, and can calculate the possible moves for the current state.