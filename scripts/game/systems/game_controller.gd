class_name GameController extends Node
## Sets up the game.


func _ready():
	GameEvents.play_pressed.connect(_setup_game)


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
	for i in Settings.ruleset.num_dice:
		EntityManager.spawn_die()
	
	# Start game
	if Settings.is_hotseat_mode:
		_start_game()
	else:
		GameEvents.opponent_ready.connect(_start_game)


func _start_game():
	GameState.current_player = General.get_random_player()
	GameState.turn_number = 0
	GameEvents.game_started.emit()
	GameEvents.new_turn_started.emit()
