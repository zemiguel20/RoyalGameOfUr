class_name MovePicker extends Node
## Calculates possible moves and selects one of the moves to execute.


@export var assigned_player: General.Player

var selector # Can be of different types

var moves: Array[GameMove] = []


func _ready() -> void:
	for node in get_children():
		selector = get_node(get_meta("selector"))
	
	if not selector:
		push_error("MovePicker: Could not find selector child node.")
	else:
		GameEvents.rolled.connect(_on_dice_rolled)
		GameEvents.roll_sequence_finished.connect(_on_roll_sequence_finished)

# NOTE: calculation of moves is separate to give feedback to other systems before changing turn
# Namely the dice and rolling label glowing red.

func _on_dice_rolled(value: int) -> void:
	if GameState.current_player != assigned_player:
		return
	
	moves.assign(_calculate_moves(value))
	
	# Check if there is any valid move
	if moves.filter(func(move: GameMove): return move.valid).is_empty():
		GameEvents.no_moves.emit()


func _calculate_moves(steps: int) -> Array[GameMove]:
	var moves: Array[GameMove] = []
	
	if steps <= 0:
		return moves
	
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
	return moves


func _on_roll_sequence_finished() -> void:
	if GameState.current_player != assigned_player:
		return
	
	if moves.is_empty():
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
		GameEvents.game_ended.emit(assigned_player)
	elif selected_move.gives_extra_turn:
		GameState.advance_turn_same_player()
	else:
		GameState.advance_turn_switch_player()
