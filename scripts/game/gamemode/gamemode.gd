class_name Gamemode
extends Node
## Controls flow of the game. It provides callback actions, and their behaviour is set by the current [Phase].


@export var board: Board
@export var dice: Dice
var current_player: int
var _phase: Phase


func _ready():
	start_game()


## Initializes the game state and context
func start_game():
	_choose_starting_player()
	board.setup()
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
	current_player = General.PlayerID.ONE if current_player == General.PlayerID.TWO else General.PlayerID.TWO


## Closes the game
func end_game():
	print("Player %d won" % current_player)


func _choose_starting_player():
	current_player = randi_range(General.PlayerID.ONE, General.PlayerID.TWO)
