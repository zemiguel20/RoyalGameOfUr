class_name RollPhase
extends Phase
## Rolling phase of the [Gamemode]. Implements behaviour for the roll action.


## Turns on dice selection highlight effects.
func start():
	# If its an ai's turn, let the ai know it can 'click' on the dice.
	if (_gamemode.is_ai_turn()):
		# Wait for a moment, Ai should not have inhumane reaction speed.
		await _gamemode.get_tree().create_timer(0.5).timeout
		_gamemode.ai_player.roll()
	else:
		_gamemode.dice.enable_selection()
		

## Turns off dice selection highlight effects.
func end():
	pass

## Rolls the dice, and then changes to the [MovePhase]. If the player rolls 0, then skip to the other player's [RollPhase] instead.
func roll():
	var value = await _gamemode.dice.roll()
	if value > 0:
		_gamemode.changeState(MovePhase.new(_gamemode))
	else:
		_gamemode.rolled_zero.emit()
		_gamemode.switch_player()
		_gamemode.changeState(RollPhase.new(_gamemode))
