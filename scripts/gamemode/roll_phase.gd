class_name RollPhase
extends Phase


func start():
	_gamemode.dice.enable_highlight()


func end():
	_gamemode.dice.disable_highlight()


func roll():
	var value = await _gamemode.dice.roll()
	if value > 0:
		_gamemode.changeState(MovePhase.new(_gamemode))
	else:
		_gamemode.switch_player()
		_gamemode.changeState(RollPhase.new(_gamemode))
