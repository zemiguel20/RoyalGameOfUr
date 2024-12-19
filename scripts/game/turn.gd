class_name Turn
## Base class for a turn controllers. Controls the actions during a turn.


signal finished(result: Result) ## Emitted when he turn finishes, after calling [method start].

enum Result {
	NORMAL,
	EXTRA_TURN,
	WIN,
	NO_MOVES,
}

var _dice: Dice
var _dice_zone: DiceZone
var _board: Board
var _scene_tree: SceneTree


## Injects the required dependencies.
func init(dice: Dice, dice_zone: DiceZone, board: Board) -> void:
	_dice = dice
	_dice_zone = dice_zone
	_board = board
	_scene_tree = board.get_tree()


## Starts the turn procedure, and emits [signal finished] to mark end of turn.
##
## NOTE: abstract function
func start() -> void:
	push_warning("Turn base class in use. Should use specific subclass instead.")
	finished.emit(Result.NO_MOVES)
