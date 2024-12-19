class_name BoardGame
extends Node
## Controls the setup and turn flow of the game.


signal ended(winner: Player)

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

var _p1_turn: Turn
var _p2_turn: Turn


func setup(new_config: Config) -> void:
	config = new_config
	
	if config.rematch:
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
		
		_p1_turn = NPCTurn.new() if config.p1_npc else PlayerTurn.new() as Turn
		_p1_turn.init(dice, p1_dice_zone, board)
		
		_p2_turn = NPCTurn.new() if config.p2_npc else PlayerTurn.new() as Turn
		_p2_turn.init(dice, p2_dice_zone, board)


func start() -> void:
	current_player = _pick_random_player()
	
	var result := Turn.Result.NORMAL
	while(result != Turn.Result.WIN):
		var turn = _p1_turn if current_player == Player.ONE else _p2_turn as Turn
		print("Starting turn player %d" % current_player)
		turn.start()
		result = await turn.finished
		
		if result == Turn.Result.NORMAL:
			_switch_player()
	
	ended.emit(current_player)
	print("game finished")


func _pick_random_dice_zone() -> DiceZone:
	if _pick_random_player() == Player.ONE:
		return p1_dice_zone
	else:
		return p2_dice_zone


func _pick_random_player() -> Player:
	return randi_range(Player.ONE, Player.TWO) as Player


func _switch_player() -> void:
	current_player = Player.TWO if current_player == Player.ONE else Player.ONE


class Config:
	var ruleset: Ruleset
	var rematch: bool
	var p1_npc: bool
	var p2_npc: bool
	
	func _init() -> void:
		ruleset = preload("res://resources/rulesets/ruleset_finkel.tres")
		rematch = false
		p1_npc = false
		p2_npc = false
