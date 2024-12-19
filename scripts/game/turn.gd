class_name Turn
## Base class for a turn controllers. Controls the actions during a turn.


signal finished(result: Result)

enum Result {
	NORMAL,
	EXTRA_TURN,
	WIN,
}

var _dice: Dice
var _dice_zone: DiceZone
var _board: Board
var _scene_tree: SceneTree


func init(dice: Dice, dice_zone: DiceZone, board: Board) -> void:
	_dice = dice
	_dice_zone = dice_zone
	_board = board
	_scene_tree = board.get_tree()


func start() -> void:
	pass
