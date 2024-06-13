class_name GameController extends Node
## Sets up the game.


func _ready():
	GameEvents.play_pressed.connect(_on_play_pressed)


func _on_play_pressed() -> void:
	_setup_game()
	
	if Settings.is_hotseat_mode:
		_start_game()
	else:
		GameEvents.opponent_ready.connect(_start_game)


func _setup_game():
	# Despawn stuff
	EntityManager.despawn_board()
	EntityManager.despawn_dice()
	
	# Spawn board according to settings
	var board = EntityManager.spawn_board(Settings.ruleset.board_layout.scene)
	
	# Spawn pieces for each player
	for i in Settings.ruleset.num_pieces:
		EntityManager.spawn_player_piece(General.Player.ONE, board)
		EntityManager.spawn_player_piece(General.Player.TWO, board)
	
	# Spawn dice
	var placing_spots: Array[Node3D] = []
	placing_spots.assign(get_tree().get_nodes_in_group("dice_placing_spots"))
	placing_spots.shuffle()
	for i in Settings.ruleset.num_dice:
		EntityManager.spawn_die(placing_spots[i].global_position)


func _start_game():
	GameState.current_player = General.get_random_player()
	GameState.turn_number = 0
	GameEvents.game_started.emit()
	GameEvents.new_turn_started.emit()
