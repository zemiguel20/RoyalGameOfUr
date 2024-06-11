class_name GameController extends Node
## Sets up the game and controls the flow of the turns.


const INTERACTIVE_MOVE_PICKER: PackedScene = preload("res://scenes/game/systems/move_picker/move_picker_interactive.tscn")
const AI_MOVE_PICKER: PackedScene = preload("res://scenes/game/systems/move_picker/move_picker_ai.tscn")

var current_player: General.Player


func _ready():
	GameEvents.intro_finished.connect(start_game)
	GameEvents.rolled.connect(_on_rolled)
	GameEvents.move_executed.connect(_on_move_executed)
	GameEvents.no_moves.connect(_on_no_moves)


func start_game():
	# Despawn stuff
	EntityManager.despawn_board()
	EntityManager.despawn_dice()
	for move_picker in get_children():
		move_picker.queue_free()
	
	# Spawn stuff according to settings
	var board = EntityManager.spawn_board(Settings.ruleset.board_layout.scene)
	
	for i in Settings.ruleset.num_pieces:
		EntityManager.spawn_player_piece(General.Player.ONE, board)
		EntityManager.spawn_player_piece(General.Player.TWO, board)
	
	for i in Settings.ruleset.num_dice:
		EntityManager.spawn_die()
	
	var p1_move_picker = INTERACTIVE_MOVE_PICKER.instantiate()
	add_child(p1_move_picker)
	var p2_move_picker = INTERACTIVE_MOVE_PICKER.instantiate() if Settings.is_hotseat_mode \
			else AI_MOVE_PICKER.instantiate()
	p2_move_picker.assigned_player = General.Player.TWO
	add_child(p2_move_picker)
	
	# Start game
	current_player = randi_range(General.Player.ONE, General.Player.TWO) as General.Player
	GameEvents.game_started.emit()
	GameEvents.roll_phase_started.emit(current_player)


func _on_rolled(roll_value: int) -> void:
	if roll_value == 0:
		_switch_player()
		GameEvents.roll_phase_started.emit(current_player)
	else:
		GameEvents.move_phase_started.emit(current_player, roll_value)


func _on_move_executed(move: GameMove):
	if move.wins:
		_end_game()
		return
	
	if not move.gives_extra_turn:
		_switch_player()
	
	GameEvents.roll_phase_started.emit(current_player)


func _on_no_moves() -> void:
	_switch_player()
	GameEvents.roll_phase_started.emit(current_player)


func _end_game():
	print("Game Finished: Player %d won" % (current_player + 1))
	GameEvents.game_ended.emit()


func _switch_player() -> void:
	current_player = General.get_opponent(current_player)
