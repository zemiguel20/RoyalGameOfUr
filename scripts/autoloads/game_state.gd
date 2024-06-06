extends Node


var current_player: int:
	set(new_player):
		current_player = new_player
		GameEvents.player_switched.emit()
