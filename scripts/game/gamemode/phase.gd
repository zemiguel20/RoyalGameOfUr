class_name Phase
extends Object
## Base state class for [Gamemode]. Represents the phases of the game.
##
## @tutorial(State pattern): https://refactoring.guru/design-patterns/state


var _gamemode: Gamemode


func _init(gamemode: Gamemode):
	_gamemode = gamemode


## Phase setup
func start():
	pass


## Phase cleanup
func end():
	pass


## Roll the dice action
func roll():
	pass


## Move [param piece] action
func move(_piece: Piece):
	pass
