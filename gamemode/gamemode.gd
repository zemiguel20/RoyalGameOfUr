class_name Gamemode
extends Node


enum Player {ONE = 1, TWO = 2}
var current_player: Player
@onready var dice = $Dice as Dice

var _phase: Phase


func _ready():
	current_player = Player.ONE
	_phase = RollPhase.new(self, dice)


func changeState(phase: Phase):
	_phase = phase


func rollDice():
	_phase.roll()


func switch_player():
	current_player = Player.TWO if current_player == Player.ONE else Player.ONE
