class_name Gamemode
extends Node


var board: Board
var dice: Dice
var current_player: int
var _phase: Phase


func _ready():
	board.setup()
	_choose_starting_player()
	_phase = RollPhase.new(self)


func changeState(phase: Phase):
	_phase.end()
	_phase = phase
	_phase.start()


func roll():
	_phase.roll()


func move(piece: Piece):
	_phase.move(piece)


func switch_player():
	# TODO: implement
	pass


func _choose_starting_player():
	# TODO: implement
	pass
