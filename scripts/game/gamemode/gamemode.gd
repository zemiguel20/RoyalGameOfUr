class_name Gamemode
extends Node
## Controls flow of the game. It provides callback actions, and their behaviour is set by the current [Phase].

signal phase_changed(phase: String, current_player: int)
signal rolled_zero
signal got_extra_roll
signal game_finished

@export var board: Board
@export var dice: Dice
@export_range(0, 10) var num_pieces_per_player: int = 7
## These values are optional, when not assigned there is hotseat.
@export var ai_player_one: AIPlayerBase
@export var ai_player_two: AIPlayerBase

var current_player: int
var _phase: Phase = Phase.new(self)

## Initializes the game state and context
func start_game():
	_choose_starting_player()
	board.setup(num_pieces_per_player)
	for piece in board.get_pieces(General.PlayerID.ONE):
		piece.clicked.connect(move)
		piece.disable_selection()
	for piece in board.get_pieces(General.PlayerID.TWO):
		piece.clicked.connect(move)
		piece.disable_selection()

	if ai_player_one != null:
		ai_player_one.setup(self, General.PlayerID.ONE)
		print_debug("Setup AI One")
	if ai_player_two != null:
		ai_player_two.setup(self, General.PlayerID.TWO)
		print_debug("Setup AI Two")		

	changeState(RollPhase.new(self))


## Cleanup current state and initialize the new [param state].
func changeState(phase: Phase):
	_phase.end()
	_phase = phase
	var phase_name: String = "Roll" if phase is RollPhase else "Move"
	phase_changed.emit(phase_name, current_player)
	_phase.start()


## Roll dice action.
func roll():
	_phase.roll()


## Move [param piece] action.
func move(piece: Piece):
	_phase.move(piece)


## Switches current player
func switch_player():
	current_player = General.PlayerID.ONE if current_player == General.PlayerID.TWO else General.PlayerID.TWO
	print("Switching to player %d" % current_player)


## Closes the game
func end_game():
	_phase.end()
	game_finished.emit()
	print("Player %d won" % current_player)
	

## Quick helper method returning whether it is the turn of an ai or not 
func is_ai_turn():
	return ((ai_player_one != null and current_player == General.PlayerID.ONE) or
		(ai_player_two != null and current_player == General.PlayerID.TWO))


func get_current_ai():
	if current_player == General.PlayerID.ONE:
		return ai_player_one
	elif current_player == General.PlayerID.TWO:
		return ai_player_two


func _choose_starting_player():
	current_player = randi_range(General.PlayerID.ONE, General.PlayerID.TWO)
	print("Player %d starting" % current_player)
