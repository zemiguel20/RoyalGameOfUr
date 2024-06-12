extends Node


var ruleset: Ruleset
var is_hotseat_mode: bool = false
var fast_move_enabled: bool = false:
	set(new_value):
		fast_move_enabled = new_value
		GameEvents.fast_move_toggled.emit(fast_move_enabled)
