class_name MovePicker extends Node
## Calculates possible moves and selects one of the moves to execute.


@export var assigned_player: General.Player

var selector # Can be of different types


func _ready() -> void:
	for node in get_children():
		selector = get_node(get_meta("selector"))
	
	if not selector:
		push_error("MovePicker: Could not find selector child node.")
	else:
		GameEvents.move_phase_started.connect(start)


## Starts the selection system for the given list of [param moves].entity_manager
func start(current_player: General.Player, last_rolled_value: int) -> void:
	if assigned_player != current_player:
		return
	
	var moves = _calculate_moves(last_rolled_value)
	
	# Check if there is any valid move
	if moves.filter(func(move: GameMove): return move.valid).is_empty():
		GameEvents.no_moves.emit()
		return
	
	if selector is AIGameMoveSelector:
		selector.start_selection(moves)
		var selected_move: GameMove = await selector.move_selected
		selected_move.execute(General.MoveAnim.ARC, true)
		await selected_move.execution_finished
		GameEvents.move_executed.emit(selected_move)
	elif selector is InteractiveGameMoveSelector:
		selector.start_selection(moves)
		var selected_move: GameMove = await selector.move_selected
		var anim = General.MoveAnim.ARC if Settings.fast_move_enabled else General.MoveAnim.LINE
		selected_move.execute(anim, Settings.fast_move_enabled)
		await selected_move.execution_finished
		GameEvents.move_executed.emit(selected_move)


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
