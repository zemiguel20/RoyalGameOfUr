extends Node


var current_player: General.Player:
	set(new_player):
		current_player = new_player
		GameEvents.player_switched.emit()
