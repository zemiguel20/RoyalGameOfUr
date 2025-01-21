class_name BoardGame
extends Node
## Controls the setup and turn flow of the game.


signal ended(winner: Player)

enum Player {
	ONE,
	TWO
}

var current_player: Player


var _config: Config = null
var _board: Board
var _p1_turn: Turn
var _p2_turn: Turn

@onready var _board_spawn: Node3D = $BoardSpawn
@onready var _p1_dice_zone: DiceZone = $DiceZoneP1
@onready var _p2_dice_zone: DiceZone = $DiceZoneP2
@onready var _dice: Dice = $DiceManager

# TODO: link setup with menus

func setup(new_config: Config) -> void:
	_config = new_config
	
	if _config.rematch:
		_board.reset()
	else:
		if _board != null: _board.queue_free()
		
		_board = _config.ruleset.board_layout.scene.instantiate() as Board
		add_child(_board)
		_board.global_position = _board_spawn.global_position
		_board.init(_config.ruleset.num_pieces)
		
		_dice.init(_config.ruleset.num_dice, _pick_random_dice_zone())
		
		_p1_turn = NPCTurn.new() if _config.p1_npc else PlayerTurn.new()
		add_child(_p1_turn)
		_p1_turn.init(Player.ONE, _dice, _p1_dice_zone, _board, _config.ruleset)
		
		_p2_turn = NPCTurn.new() if _config.p2_npc else PlayerTurn.new()
		add_child(_p2_turn)
		_p2_turn.init(Player.TWO, _dice, _p2_dice_zone, _board, _config.ruleset)


func start() -> void:
	current_player = _pick_random_player()
	
	var result := Turn.Result.NORMAL
	while(result != Turn.Result.WIN):
		var turn = _p1_turn if current_player == Player.ONE else _p2_turn as Turn
		print("Starting turn player %d" % current_player)
		turn.start()
		result = await turn.finished
		
		if result == Turn.Result.NORMAL or result == Turn.Result.NO_MOVES:
			_switch_player()
	
	ended.emit(current_player)
	print("game finished")


func _pick_random_dice_zone() -> DiceZone:
	if _pick_random_player() == Player.ONE:
		return _p1_dice_zone
	else:
		return _p2_dice_zone


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
		ruleset = General.RULESET_FINKEL
		rematch = false
		p1_npc = false
		p2_npc = false
