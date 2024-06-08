class_name GameController extends Node
## Sets up the game and controls the flow of the turns.


@export var die_spawn_point: Node3D

var current_player: General.Player


func _ready():
	EntityManager.clear_dice()
	for i in Settings.num_dice:
		EntityManager.spawn_die(die_spawn_point.global_position)
	
	GameEvents.intro_finished.connect(start_game)
	GameEvents.rolled.connect(_on_rolled)
	GameEvents.move_executed.connect(_on_move_executed)
	GameEvents.no_moves.connect(_on_no_moves)
	

func start_game():
	EntityManager.clear_pieces()
	for i in Settings.num_pieces:
		EntityManager.spawn_player_piece(General.Player.ONE)
		EntityManager.spawn_player_piece(General.Player.TWO)
	
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
	GameEvents.game_ended.emit(current_player + 1)


func _switch_player() -> void:
	current_player = General.get_opponent(current_player)
