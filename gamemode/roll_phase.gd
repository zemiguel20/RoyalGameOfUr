class_name RollPhase
extends Phase


var _dice: Dice


func _init(gamemode: Gamemode, dice: Dice):
	super._init(gamemode)
	_dice = dice


func roll() -> void:
	var value = await _dice.roll()
	print("Player %d rolled %d" % [_gamemode.current_player, value])
	# TODO: implement move phase
	_gamemode.switch_player()
	_gamemode.changeState(RollPhase.new(_gamemode, _dice))
