extends Node


var current_player: General.Player = General.Player.ONE ## Player playing the current turn.
var turn_number: int = 0 ## Total count of the number of turns of the current match.

var is_rematch := false
var is_hotseat := false
var fast_move_enabled := false

var ruleset
var game_aborted_flag


func start_new_game() -> void:
	_setup_board()
	
	if not is_hotseat:
		await GameEvents.opponent_ready
	
	if not game_aborted_flag:
		current_player = General.get_random_player()
		turn_number = 0
		GameEvents.game_started.emit()
		GameEvents.new_turn_started.emit()
		game_aborted_flag = false
	
	
func on_back_to_main_menu():
	game_aborted_flag = true
	GameEvents.opponent_ready.emit()


func _setup_board():
	if is_rematch:
		# Reset pieces
		var board: Board = EntityManager.get_board() as Board
		for spot in board.get_track_spots_occupied_by_self(General.Player.ONE):
			var free_start_spots = board.get_free_start_spots(General.Player.ONE)
			spot.move_pieces_split_to_spots(free_start_spots, General.MoveAnim.ARC)
		for spot in board.get_track_spots_occupied_by_self(General.Player.TWO):
			var free_start_spots = board.get_free_start_spots(General.Player.TWO)
			spot.move_pieces_split_to_spots(free_start_spots, General.MoveAnim.ARC)
	else:
		# Despawn stuff
		EntityManager.despawn_board()
		EntityManager.despawn_dice()
		
		# Spawn board according to settings
		var board = EntityManager.spawn_board(ruleset.board_layout.scene)
		
		# Spawn pieces for each player
		for i in ruleset.num_pieces:
			EntityManager.spawn_player_piece(General.Player.ONE, board)
			EntityManager.spawn_player_piece(General.Player.TWO, board)
		
		# Spawn dice
		var placing_spots: Array[Node3D] = []
		placing_spots.assign(get_tree().get_nodes_in_group("dice_placing_spots"))
		placing_spots.shuffle()
		for i in ruleset.num_dice:
			EntityManager.spawn_die(placing_spots[i].global_position)


## Advance turn and switch players.
func advance_turn_switch_player() -> void:
	current_player = General.get_opponent(current_player)
	turn_number += 1
	GameEvents.new_turn_started.emit()


## Advance turn as an extra turn for current player.
func advance_turn_same_player() -> void:
	turn_number += 1
	GameEvents.new_turn_started.emit()


func is_bot_playing() -> bool:
	return current_player == General.Player.TWO and not is_hotseat
