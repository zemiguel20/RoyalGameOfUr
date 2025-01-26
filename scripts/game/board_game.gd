class_name BoardGame
extends Node
## Controls the setup and turn flow of the game.


signal ended(winner: Player)

enum Player {
	ONE,
	TWO
}

var _config: Config = null
var _current_player: Player
var _board: Board
var _dice: Array[Die] = []
var _p1_turn: TurnController
var _p2_turn: TurnController

@onready var _board_spawn: Node3D = $BoardSpawn
@onready var _p1_dice_zone: DiceZone = $DiceZoneP1
@onready var _p2_dice_zone: DiceZone = $DiceZoneP2


func setup(new_config: Config) -> void:
	_config = new_config
	
	if _config.rematch:
		_board.reset()
	else:
		_despaw_objects()
		_spawn_board(_config.ruleset.board_layout.scene, _config.ruleset.num_pieces)
		_spawn_dice(_config.ruleset.num_dice)
		_p1_turn = _create_player_turn_controller(Player.ONE, _config.p1_npc)
		_p2_turn = _create_player_turn_controller(Player.TWO, _config.p2_npc)


func start() -> void:
	_current_player = _pick_random_player()
	
	var result := TurnController.Result.NORMAL
	while(result != TurnController.Result.WIN):
		var turn = _p1_turn if _current_player == Player.ONE else _p2_turn as TurnController
		print("Starting turn player %d" % _current_player)
		turn.start_turn()
		result = await turn.turn_finished
		
		if result == TurnController.Result.NORMAL or result == TurnController.Result.NO_MOVES:
			_switch_player()
	
	ended.emit(_current_player)
	print("game finished")


func _despaw_objects() -> void:
	if _board != null:
		_board.queue_free()
	for die in _dice:
		die.queue_free()
	if _p1_turn != null:
		_p1_turn.queue_free()
	if _p2_turn != null:
		_p2_turn.queue_free()


func _spawn_board(scene: PackedScene, num_pieces: int) -> void:
	_board = scene.instantiate() as Board
	add_child(_board)
	_board.global_position = _board_spawn.global_position
	_board.init(num_pieces)


func _spawn_dice(num_dice: int) -> void:
	var spawn_zone = _p1_dice_zone if _pick_random_player() == Player.ONE else _p2_dice_zone
	_dice = spawn_zone.spawn_dice(num_dice)


# NOTE: assumes everything else to be spawned first, to reduce parameter number
func _create_player_turn_controller(player: Player, npc: bool) -> TurnController:
	var turn_controller = TurnController.new()
	turn_controller.name = "TurnControllerP%d" % player
	add_child(turn_controller)
	
	var roll_controller = \
		AutoRollController.new() if npc else InteractiveRollController.new() as RollController
	roll_controller.name = "RollControllerP%d" % player
	turn_controller.add_child(roll_controller)
	var dice_zone = _p1_dice_zone if player == Player.ONE else _p2_dice_zone
	roll_controller.init(_dice, dice_zone)
	
	var move_selector = \
		AIGameMoveSelector.new() if npc else InteractiveGameMoveSelector.new() as GameMoveSelector
	move_selector.name = "MoveSelectorP%d" % player
	turn_controller.add_child(move_selector)
	
	turn_controller.init(player, roll_controller, move_selector, _board, _config.ruleset)
	
	return turn_controller


func _pick_random_player() -> Player:
	return randi_range(Player.ONE, Player.TWO) as Player


func _switch_player() -> void:
	_current_player = get_opponent(_current_player)


static func get_opponent(player: Player) -> Player:
	return Player.TWO if player == Player.ONE else Player.ONE


class Config:
	var ruleset: Ruleset
	var rematch: bool
	var p1_npc: bool
	var p2_npc: bool
	var hotseat: bool
	
	func _init() -> void:
		ruleset = load("res://resources/rulesets/ruleset_finkel.tres")
		rematch = false
		p1_npc = false
		p2_npc = true
		hotseat = false
