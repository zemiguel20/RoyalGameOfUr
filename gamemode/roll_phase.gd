class_name RollPhase
extends Phase


func roll() -> void:
	var value = await _gamemode.dice.roll()
	print("Player %d rolled %d" % [_gamemode.current_player, value])
	if value == 0:
		print("Rolled 0. Skipping turn...")
		_gamemode._switch_player()
		_gamemode._changeState(RollPhase.new(_gamemode))
	else:
		_gamemode._changeState(MovePhase.new(_gamemode))
