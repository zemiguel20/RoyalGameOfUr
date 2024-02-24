class_name Gamemode
extends Node
## Controls flow of the game. It provides callback actions, and their behaviour is set by the current [Phase].


var board: Board
var dice: Dice
var current_player: int
var _phase: Phase


func _ready():
	start_game()


## Initializes the game state and context
func start_game():
	board.setup()
	_choose_starting_player()
	_phase = RollPhase.new(self)


## Cleanup current state and initialize the new [param state].
func changeState(phase: Phase):
	_phase.end()
	_phase = phase
	_phase.start()


## Roll dice action.
func roll():
	_phase.roll()


## Move [param piece] action.
func move(piece: Piece):
	_phase.move(piece)


## Switches current player
func switch_player():
	# TODO: implement
	pass


## Closes the game
func end_game():
	pass


func _choose_starting_player():
	current_player = randi_range(General.PlayerID.ONE, General.PlayerID.TWO)
