class_name Dice
extends Node


signal diceClicked
var _selectable = true

## Mock dice selection
func _process(delta):
	if _selectable and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		diceClicked.emit()


## Mock functions, rolls and returns roll value
func roll() -> int:
	_selectable = false
	print("Playing roll animation...")
	await get_tree().create_timer(1.0).timeout
	print("Finished rolling animation...")
	_selectable = true
	var roll = randi_range(0, 4)
	return roll
