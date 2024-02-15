class_name RollPhase
extends Phase


func roll() -> void:
	var value = await _gamemode.dice.roll()
	print("Player %d rolled %d" % [_gamemode.current_player, value])
	if value == 0:
		print("Rolled 0. Skipping turn...")
		_gamemode.switch_player()
		_gamemode.changeState(RollPhase.new(_gamemode))
	else:
		_gamemode.changeState(MovePhase.new(_gamemode))
