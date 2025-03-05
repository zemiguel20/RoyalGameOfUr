# Main and Level scenes

The `Main` scene serves as the starting point of the game. It contains some UI scenes, including the splash screen and the main menu, and the `Level` scene which contains our game environment, gameplay related nodes, like the systems, camera, and NPC, and game UI, like the HUD or pause menu.

The environment also serves as the background for the main menu, so the `Main` scene reloads the `Level` scene every time the player goes back to the main menu. To speed-up boot time, `Main` loads `Level` using a separate thread while the splash screen is playing.

The `Level` coordinates the different gameplay nodes.

# Core gameplay

## Entities

### Die
The die is rolled with physics, so the root node type is `RigidBody3D`. Contains as component child nodes a `MeshHighlighter` to allow highlighting, a `SelectionInputReader` to read game input, and a `SimpleMovementAnimationPlayer` to move the die around without using physics.
There is also a `DieTip` node for each tip of the die. This node function has the normal vector of the tip (used to know which one is facing up) and has a roll value defined.

The `Die` type extends the root node providing the API to interact with the components of the die and implements the roll logic.

The scene file name is `d4_die.tscn`.

### Piece
The piece is a simple 3D object that is moved around. It contains a `MeshHighlighter` node to allow highlighting the piece model and a `SimpleMovementAnimationPlayer` node to allow moving the piece around the board.
The root node is a `Node3D` of type `Piece`. This script provides the API to move and highlight the piece.

It has a base scene `piece_base.tscn` with 2 variations `piece_black.tscn` and `piece_white.tscn`. These variations add the corresponding black and white materials. 

## Spot
The spot represents a place where pieces can be placed. Also, it is the selection target when choosing a move, since we move pieces *from* a spot *to* another spot. It contains a `SelectionInputReader` node that allows reading the input, and a `MeshHighlighter` node paired with an invisible mesh to allow highlighting the spot area.
The root node is a `Node3D` of type `Spot`, which provides an API to the input, highlight, and logic for placing pieces.

The scene file name is `spot.tscn`.

### Board
The board is a collection of spots placed accordingly in and around the board model. For each player, it has a set of spots that represent the starting zone, and a sequence of spots representing the track.
The root node is a `Node3D` of type `Board`. It has a set of lists exposed to the editor, so that the spots can be assigned as starting spots or as part of the track.

Each type of board has their own dedicated scene, where the track can be changed. So the Finkel board is in the `board_finkel.tscn` scene, and the Masters board is in the `board_masters.tscn` scene.

The `Board` spawns the pieces, allows queries to the state of the board, and can calculate the possible moves for the current state.

### Custom components

#### `MeshHighlighter`

This node simply applies a given highlight `Material` resource to a target `MeshInstance3D` by setting its `material_overlay` property. It provides a `set_active(bool)` function to turn the highlight on and off, and a `set_color(Color)` function to change the highlight color. If the highlight material is not a `StandardMaterial3D`, then it assumes a `color` property in the shader. 

#### `SelectionInputReader`

This node extends the `Area3D` node with functionality to read player mouse input and distinguish between a click and a hold. If the user keeps keeps the button pressed longer than the time threshold then it reads an hold and emits the `hold_started` signal. Otherwise it reads a click and emits the `clicked` signal. If holding, when the button is released then it emits the `hold_stopped` signal.
The `hold_threshold` property defines the time threshold in seconds.

#### `SimpleMovementAnimationPlayer`

This node provides a set of animations to move the object to a target point in global space. The animations are ran using a `Tween`. Currently it supports two animations: the `move_line` function moves in a straight line with an ease-out function; and the `move_arc` function moves in an arc with a specified height.
The `movement_finished` signal is emitted once the animation finishes.

## Systems

The `board_game.tscn` scene contains the main parts of the core game. At the root there is a `BoardGame` node which is the main controller of the game. The entities are spawned dynamically according to the game settings.
It has a `Node3D` that acts as the spawn point for the board, and two `DiceZone` instances, one for each player. It also has a `StaticBody3D` that acts as the floor/table for the dice to roll on.

### `DiceZone`

The `DiceZone` is a node that is essentially a container of 2 sets of `Node3D` points. One set represents the placing points, used when the dice are passed between players when the turns change. The other set represents throwing points, used when tossing the dice.

The `DiceZone` is also used to spawn the dice. The placing spots are used as spawning points.

### `Ruleset`

The `Ruleset` is a resource that contains the properties of a ruleset, such as number of dice and pieces per player, and the effects of a rosette tile. It also contains the used board, represented as a `BoardLayout` resource. The `BoardLayout` is simply a metadata wrapper for each different `Board` scene, having a name, preview image, and the reference to the respective `Board` scene.

For each different ruleset there is a `Ruleset` resource instance.

### Game setup

The `BoardGame` node provides a `setup(Config)` function that sets up the game and board by spawning all the necessary objects.
The `Config` struct contains the game configuration and setting, including the `Ruleset` and if player 1 and/or 2 are NPCs or not.

The `BoardGame` uses one of the `DiceZone` instances to spawn the dice, spawns the board in the board spawn point, and then uses this `Board` instance to spawn the player pieces.

For each player it will create a `TurnController` instance and configure it according to whether they are a player or NPC.

