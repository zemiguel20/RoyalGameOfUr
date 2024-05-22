class_name MovePicker
extends Node
## Base interface for move picker systems. Has a function to start the system by giving it a list
## of moves. Once a move is selected (by whatever implementation), it executes that move and
## the [code]move_picked[/code] signal should be emited.


signal move_executed(move : Move)
signal on_play_dialogue(category: DialogueSystem.Category)
signal on_play_tutorial_dialogue(category: DialogueSystem.Category)

var has_emitted_tutorial_capture_signal


## Starts the selection system for the given list of [param moves].
func start(moves : Array[Move]) -> void:
	pass
