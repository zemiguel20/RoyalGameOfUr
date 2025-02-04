class_name BoardGame
extends Node
## Controls the setup and turn flow of the game.


signal ended(winner: Player)

enum Player {
	ONE,
	TWO
}

var config: Config = null
var current_player: Player
var p1_turn_controller: TurnController
var p2_turn_controller: TurnController
var turn_number: int = 0
var board: Board
var dice: Array[Die] = []
var turn_history: Array[TurnController.TurnSummary] = []

var _running: bool = false # used for TESTING

@onready var _board_spawn: Node3D = $BoardSpawn
@onready var _p1_dice_zone: DiceZone = $DiceZoneP1
@onready var _p2_dice_zone: DiceZone = $DiceZoneP2


static func get_opponent(player: Player) -> Player:
	return Player.TWO if player == Player.ONE else Player.ONE


# NOTE: ONLY FOR TESTING
func _input(event: InputEvent) -> void:
	if event is InputEventKey and OS.is_debug_build():
		if event.pressed and event.keycode == KEY_0 and _running:
			_end_game()


func setup(new_config: Config) -> void:
	config = new_config
	turn_history.clear()
	
	if config.rematch:
		board.reset()
	else:
		_despaw_objects()
		_spawn_board(config.ruleset.board_layout.scene, config.ruleset.num_pieces)
		_spawn_dice()
	
	_delete_controllers()
	p1_turn_controller = _create_player_turn_controller(Player.ONE, config.p1_npc)
	p2_turn_controller = _create_player_turn_controller(Player.TWO, config.p2_npc)


func start() -> void:
	current_player = _pick_random_player()
	turn_number = 1
	_running = true
	_get_turn_controller().start_turn()


func _despaw_objects() -> void:
	if board != null:
		board.queue_free()
	for die in dice:
		die.queue_free()


func _delete_controllers() -> void:
	if p1_turn_controller != null:
		p1_turn_controller.queue_free()
	if p2_turn_controller != null:
		p2_turn_controller.queue_free()


func _spawn_board(scene: PackedScene, num_pieces: int) -> void:
	board = scene.instantiate() as Board
	add_child(board)
	board.global_position = _board_spawn.global_position
	board.init(num_pieces)


func _spawn_dice() -> void:
	var spawn_zone: DiceZone
	if _pick_random_player() == Player.ONE:
		spawn_zone = _p1_dice_zone
	else:
		spawn_zone = _p2_dice_zone
	dice = spawn_zone.spawn_dice(config.ruleset.num_dice)


# NOTE: assumes everything else to be spawned first, to reduce parameter number
func _create_player_turn_controller(player: Player, npc: bool) -> TurnController:
	var turn_controller = TurnController.new()
	turn_controller.name = "TurnControllerP%d" % player
	add_child(turn_controller)
	
	var roll_controller: RollController
	if npc:
		roll_controller = AutoRollController.new()
	else:
		roll_controller = InteractiveRollController.new()
	roll_controller.name = "RollControllerP%d" % player
	turn_controller.add_child(roll_controller)
	var dice_zone = _p1_dice_zone if player == Player.ONE else _p2_dice_zone
	roll_controller.init(dice, dice_zone)
	
	var move_selector: GameMoveSelector
	if npc:
		move_selector = AIGameMoveSelector.new()
		move_selector.init(board)
	else:
		move_selector = InteractiveGameMoveSelector.new()
	move_selector.name = "MoveSelectorP%d" % player
	turn_controller.add_child(move_selector)
	
	turn_controller.init(player, roll_controller, move_selector, board, config.ruleset)
	
	turn_controller.turn_finished.connect(_on_turn_finished)
	
	return turn_controller


func _pick_random_player() -> Player:
	return randi_range(Player.ONE, Player.TWO) as Player


func _on_turn_finished(summary: TurnController.TurnSummary) -> void:
	turn_history.append(summary)
	
	const Result = TurnController.TurnSummary.Result
	if summary.result == Result.WIN:
		_end_game()
	else:
		if summary.result != Result.EXTRA_TURN:
			_switch_player()
		turn_number += 1
		_get_turn_controller().start_turn()


func _get_turn_controller() -> TurnController:
	if current_player == Player.ONE:
		return p1_turn_controller
	else:
		return p2_turn_controller


func _switch_player() -> void:
	current_player = get_opponent(current_player)


func _end_game() -> void:
	_running = false
	ended.emit(current_player)


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
