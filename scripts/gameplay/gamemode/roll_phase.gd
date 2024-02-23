class_name RollPhase
extends Phase
## Rolling phase of the [Gamemode]. Implements behaviour for the roll action.


## Turns on dice selection highlight effects.
func start():
	_gamemode.dice.enable_selection()


## Turns off dice selection highlight effects.
func end():
	_gamemode.dice.disable_selection()


## Rolls the dice, and then changes to the [MovePhase]. If the player rolls 0, then skip to the other player's [RollPhase] instead.
func roll():
	var value = await _gamemode.dice.roll()
	if value > 0:
		_gamemode.changeState(MovePhase.new(_gamemode))
	else:
		_gamemode.switch_player()
		_gamemode.changeState(RollPhase.new(_gamemode))
