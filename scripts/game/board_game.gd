class_name BoardGame
extends Node


enum Player {
	ONE,
	TWO
}

@export var board_spawn: Node3D
@export var p1_dice_zone: DiceZone
@export var p2_dice_zone: DiceZone

var current_player: Player
var config: Config = null
var board: Board
var dice: Dice


func setup(new_config: Config) -> void:
	config = new_config
	
	if config.is_rematch:
		board.reset()
	else:
		if board != null: board.queue_free()
		if dice != null: dice.queue_free()
		
		
		board = config.ruleset.board_layout.scene.instantiate() as Board
		add_child(board)
		board.global_position = board_spawn.global_position
		board.init(config.ruleset.num_pieces)
		
		dice = Dice.new()
		add_child(dice)
		dice.init(config.ruleset.num_dice, _pick_random_dice_zone())


func start() -> void:
	# TODO: implement
	current_player = _pick_random_player()


# Pick a side to initialize the dice
func _pick_random_dice_zone() -> DiceZone:
	if _pick_random_player() == Player.ONE:
		return p1_dice_zone
	else:
		return p2_dice_zone


func _pick_random_player() -> Player:
	return randi_range(Player.ONE, Player.TWO) as Player


class Config:
	var ruleset: Ruleset
	var is_rematch: bool
