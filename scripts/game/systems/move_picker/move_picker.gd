class_name MovePicker extends Node
## Calculates possible moves and selects one of the moves to execute.
# NOTE: calculation of moves is separated from the actual move picking phase
# to give feedback to other systems before changing turn, namely the dice
# and roll result label glowing red.

@export var assigned_player: General.Player

var selector # Can be of different types
var moves: Array[GameMove] = []
var valid_moves_filter = func(move: GameMove): return move.valid


func _ready() -> void:
	for node in get_children():
		selector = get_node(get_meta("selector"))
	
	if not selector:
		push_error("MovePicker: Could not find selector child node.")
	else:
		GameEvents.new_turn_started.connect(_on_new_turn_started)


func _on_new_turn_started() -> void:
	if GameState.current_player == assigned_player:
		if not GameEvents.rolled.is_connected(_on_dice_rolled):
			GameEvents.rolled.connect(_on_dice_rolled)
		if not GameEvents.roll_sequence_finished.is_connected(_on_roll_sequence_finished):
			GameEvents.roll_sequence_finished.connect(_on_roll_sequence_finished)
	else:
		if GameEvents.rolled.is_connected(_on_dice_rolled):
			GameEvents.rolled.disconnect(_on_dice_rolled)
		if GameEvents.roll_sequence_finished.is_connected(_on_roll_sequence_finished):
			GameEvents.roll_sequence_finished.disconnect(_on_roll_sequence_finished)


func _on_dice_rolled(value: int) -> void:
	_calculate_moves(value)
	
	# Check if there is any valid move
	if moves.filter(valid_moves_filter).is_empty():
		GameEvents.no_moves.emit()


func _calculate_moves(steps: int) -> void:
	moves.clear()
	
	if steps <= 0:
		return
	
	var board = EntityManager.get_board()
	
	# Get all spots where the current player has pieces
	var occupied_start_spots = board.get_occupied_start_spots(assigned_player)
	var occupied_track_spots = board.get_track_spots_occupied_by_self(assigned_player)
	var occupied_spots: Array[Spot] = occupied_start_spots + occupied_track_spots
	
	# Calculate all moves and whether they are valid
	for spot in occupied_spots:
		var landing_spots = board.get_landing_spots(assigned_player, spot, steps, \
			not Settings.ruleset.can_move_backwards)
		
		for landing_spot in landing_spots:
			var move = GameMove.new(spot, landing_spot, assigned_player)
			moves.append(move)


func _on_roll_sequence_finished() -> void:
	if moves.filter(valid_moves_filter).is_empty():
		GameState.advance_turn_switch_player()
		return
	
	selector.start_selection(moves)
	var selected_move: GameMove = await selector.move_selected
	var anim = General.MoveAnim.ARC if (selector is AIGameMoveSelector or Settings.fast_move_enabled) \
		else General.MoveAnim.LINE
	var follow_path = true if (selector is AIGameMoveSelector or Settings.fast_move_enabled) else false
	selected_move.execute(anim, follow_path)
	await selected_move.execution_finished
	GameEvents.move_executed.emit(selected_move)
	
	if selected_move.wins:
		GameEvents.game_ended.emit()
	elif selected_move.gives_extra_turn:
		GameState.advance_turn_same_player()
	else:
		GameState.advance_turn_switch_player()
