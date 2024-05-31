class_name GameController extends Node
## Sets up the game and controls the turns of the game and delegates actions like rolling
## and picking a move to specialized systems. Works based on game settings / rules.


signal game_started
signal roll_phase_started(player: General.Player)
signal move_phase_started(player: General.Player, moves: Array[Move])
signal game_ended
signal no_moves

@export var p1_move_picker: MovePicker
@export var p2_move_picker: MovePicker
@export var p1_dice_roller: DiceRoller
@export var p2_dice_roller: DiceRoller
@export var entity_manager: EntityManager

var current_player : int


func _ready():
	entity_manager.spawn_player_pieces(Settings.num_pieces)
	entity_manager.spawn_dice(Settings.num_dice)


func start_game():
	current_player = randi_range(General.Player.ONE, General.Player.TWO)
	game_started.emit()
	_start_roll_phase()


func get_current_player_dice_roller() -> DiceRoller:
	if current_player == General.Player.ONE:
		return p1_dice_roller
	else:
		return p2_dice_roller


func get_current_player_move_picker() -> MovePicker:
	if current_player == General.Player.ONE:
		return p1_move_picker
	else:
		return p2_move_picker


func _start_roll_phase():
	var roller = get_current_player_dice_roller()
	
	roller.place_dice(entity_manager.dice)
	await roller.dice_placed
	
	roller.start(entity_manager.dice)
	roller.roll_finished.connect(_on_roll_ended)
	
	roll_phase_started.emit(current_player)


func _on_roll_ended(roll_value: int):
	var roller = get_current_player_dice_roller()
	roller.roll_finished.disconnect(_on_roll_ended)
	
	if roll_value == 0:
		_switch_player()
		_start_roll_phase()
	else:
		_start_move_phase(roll_value)


func _start_move_phase(roll_value: int):
	var moves = _calculate_possible_moves(roll_value)
	if not moves.is_empty():
		var move_picker = get_current_player_move_picker()
		move_picker.start(moves)
	else:
		no_moves.emit()
		_switch_player()
		_start_roll_phase()


func _on_move_executed(move: Move):
	if move.wins:
		_end_game()
		return
	
	if not move.gives_extra_turn:
		_switch_player()
	_start_roll_phase()


func _end_game():
	print("Game Finished: Player %d won" % (current_player + 1))
	game_ended.emit()


func _switch_player() -> void:
	current_player = General.get_opponent(current_player)


func _calculate_possible_moves(steps: int) -> Array[Move]:
	push_error("NOT IMPLEMENTED") # TODO: copy code from Board.gd
	return []
