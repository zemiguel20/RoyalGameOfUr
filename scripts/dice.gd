class_name Dice
extends Node
## Dice controller. Controls the dice rolling animation and stores its value.


signal clicked
var value: int ## Current rolled value.


## Enables highlight effects
func enable_highlight():
	# TODO: implement
	pass


## Disables highlight effects
func disable_highlight():
	# TODO: implement
	pass


## Plays the dice rolling animation and updates the value. Returns the rolled value.
func roll() -> int:
	# TODO: implement: roll animation and read value
	value = randi_range(0, 4)
	return value


func _on_input_selected():
	clicked.emit()
