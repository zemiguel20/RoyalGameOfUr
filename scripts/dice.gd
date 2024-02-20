class_name Dice
extends Node


signal clicked
var value: int


func enable_highlight():
	# TODO: implement
	pass


func disable_highlight():
	# TODO: implement
	pass


func roll() -> int:
	# TODO: implement: roll animation and read value
	value = randi_range(0, 4)
	return value


# TODO: implement actual callback
func _on_input_selected():
	clicked.emit()
