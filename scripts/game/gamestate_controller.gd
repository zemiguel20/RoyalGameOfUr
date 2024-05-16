class_name GameStateController
extends Node


signal game_started
signal roll_phase_started(player: General.Player)
signal move_phase_started(player: General.Player, moves: Array[Move])
signal game_ended
signal no_moves

@export var _board: Board
@export var p1_move_picker : MovePicker
@export var p2_move_picker : MovePicker
@export var dice : Dice

var current_player : int


func _ready():
	p1_move_picker.move_executed.connect(_on_move_executed)
	p2_move_picker.move_executed.connect(_on_move_executed)
	dice.roll_finished.connect(_on_roll_ended)


func start_game():
	current_player = randi_range(General.Player.ONE, General.Player.TWO)
	game_started.emit()
	dice.on_roll_phase_started(current_player)
	

func end_game():
	print("Game Finished: Player %d won" % (current_player + 1))
	game_ended.emit()


func _on_roll_ended(roll_value: int):
	var moves = _board.get_possible_moves(current_player, roll_value)
	if not moves.is_empty():
		match current_player:
			General.Player.ONE:
				p1_move_picker.start(moves)
			General.Player.TWO:
				p2_move_picker.start(moves)
	else:
		no_moves.emit()
		current_player = General.get_opponent(current_player)
		dice.on_roll_phase_started(current_player)


func _on_move_executed(move: Move):
	if move.wins:
		end_game()
		return
	
	if not move.gives_extra_turn:
		current_player = General.get_opponent(current_player)
	dice.on_roll_phase_started(current_player)
