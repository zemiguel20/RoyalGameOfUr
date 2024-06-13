class_name GameController extends Node
## Sets up the game.


const INTERACTIVE_MOVE_PICKER: PackedScene = \
	preload("res://scenes/game/systems/move_picker/move_picker_interactive.tscn")
const AI_MOVE_PICKER: PackedScene = \
	preload("res://scenes/game/systems/move_picker/move_picker_ai.tscn")


func _ready():
	GameEvents.play_pressed.connect(_setup_game)


func _setup_game():
	# Despawn stuff
	EntityManager.despawn_board()
	EntityManager.despawn_dice()
	for move_picker in get_children():
		move_picker.queue_free()
	
	# Spawn board according to settings
	var board = EntityManager.spawn_board(Settings.ruleset.board_layout.scene)
	
	# Spawn pieces for each player
	for i in Settings.ruleset.num_pieces:
		EntityManager.spawn_player_piece(General.Player.ONE, board)
		EntityManager.spawn_player_piece(General.Player.TWO, board)
	
	# Spawn dice
	for i in Settings.ruleset.num_dice:
		EntityManager.spawn_die()
	
	# Create move picker for P1
	var p1_move_picker = INTERACTIVE_MOVE_PICKER.instantiate()
	p1_move_picker.assigned_player = General.Player.ONE
	add_child(p1_move_picker)
	
	# Create move picker for P2
	var p2_move_picker = INTERACTIVE_MOVE_PICKER.instantiate() if Settings.is_hotseat_mode \
			else AI_MOVE_PICKER.instantiate()
	p2_move_picker.assigned_player = General.Player.TWO
	add_child(p2_move_picker)
	
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
