class_name GameController extends Node
## Sets up the game and controls the turns of the game and delegates actions like rolling
## and picking a move to specialized systems. Works based on game settings / rules.


signal game_started
signal roll_phase_started(player: General.Player)
signal move_phase_started(player: General.Player, moves: Array[GameMove])
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
	var moves = _calculate_moves(roll_value)
	
	var valid_move_filter = func(move: GameMove): return move.valid
	
	if not moves.filter(valid_move_filter).is_empty():
		var move_picker = get_current_player_move_picker()
		move_picker.start(moves) # NOTE: pass in all moves, including invalid for display
	else:
		no_moves.emit()
		_switch_player()
		_start_roll_phase()


func _on_move_executed(move: GameMove):
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


func _calculate_moves(steps: int) -> Array[GameMove]:
	var moves: Array[GameMove] = []
	
	if steps <= 0:
		return moves
	
	var board = entity_manager.board
	
	# Get all spots where the current player has pieces
	var occupied_start_spots = board.get_occupied_start_spots(current_player)
	var occupied_track_spots = board.get_track_spots_occupied_by_self(current_player)
	var occupied_spots: Array[Spot] = occupied_start_spots + occupied_track_spots
	
	# Calculate all moves and whether they are valid
	for spot in occupied_spots:
		var landing_spots = board.get_landing_spots(current_player, spot, steps, not Settings.can_move_backwards)
		for landing_spot in landing_spots:
			var valid = _can_place(landing_spot, current_player)
			var move = GameMove.new(spot, landing_spot, current_player, valid, entity_manager.board)
			moves.append(move)
	return moves


# Check if any rules are violated, or return true.
func _can_place(spot: Spot, player: int) -> bool:
	var result = true
	
	if spot.is_occupied_by_player(player) and not spot.safe \
	and not entity_manager.board.is_spot_end_of_player_track(spot, player):
		result = false
	
	if spot.is_occupied_by_player(player) and spot.safe and not Settings.can_stack_in_safe_spot:
		result = false
	
	if spot.is_occupied_by_player(General.get_opponent(player)) and spot.safe:
		result = false
	
	return result
