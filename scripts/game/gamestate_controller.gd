extends Node


signal roll_phase_started(player: General.Player)
signal move_phase_started(player: General.Player, roll_value: int)

var current_player: General.Player


func start_game():
	current_player = randi_range(General.Player.ONE, General.Player.TWO) as General.Player
	roll_phase_started.emit(current_player)


func end_game():
	print("Game Finished: Player %d won" % (current_player + 1))


func _on_roll_ended(roll_value: int):
	if roll_value > 0:
		move_phase_started.emit(current_player, roll_value)
	else:
		_switch_player()
		roll_phase_started.emit(current_player)


func _on_move_executed(move: Move):
	if move.is_winning_move():
		end_game()
		return
	
	if not move.gives_extra_roll():
		_switch_player()
	roll_phase_started.emit(current_player)


func _switch_player():
	current_player = General.Player.ONE if current_player == General.Player.TWO \
		else General.Player.TWO
