class_name MovePicker extends Node
## Calculates possible moves and selects one of the moves to execute.
# NOTE: calculation of moves is separated from the actual move picking phase
# to give feedback to other systems before changing turn, namely the dice
# and roll result label glowing red.


var selector_interactive: InteractiveGameMoveSelector
var selector_ai: AIGameMoveSelector

var moves: Array[GameMove] = []
var valid_moves_filter = func(move: GameMove): return move.valid


func _ready() -> void:
	selector_interactive = get_node(get_meta("selector_interactive"))
	selector_ai = get_node(get_meta("selector_ai"))
	
	GameEvents.rolled.connect(_on_dice_rolled)
	GameEvents.roll_sequence_finished.connect(_on_roll_sequence_finished)
	GameEvents.game_ended.connect(_on_game_ended)
	GameEvents.back_to_main_menu_pressed.connect(_on_game_ended)


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
	var player = GameManager.current_player
	
	# Get all spots where the current player has pieces
	var occupied_start_spots = board.get_occupied_start_spots(player)
	var occupied_track_spots = board.get_track_spots_occupied_by_self(player)
	var occupied_spots: Array[Spot] = occupied_start_spots + occupied_track_spots
	
	# Calculate all moves and whether they are valid
	for spot in occupied_spots:
		var landing_spots = board.get_landing_spots(player, spot, steps, \
			not GameManager.ruleset.can_move_backwards)
		
		for landing_spot in landing_spots:
			var move = GameMove.new(spot, landing_spot, player)
			moves.append(move)


func _on_roll_sequence_finished() -> void:
	if moves.filter(valid_moves_filter).is_empty():
		GameManager.advance_turn_switch_player()
		return
	
	var selected_move: GameMove
	
	if GameManager.is_bot_playing():
		selector_ai.start_selection(moves)
		selected_move = await selector_ai.move_selected
		selected_move.execute(General.MoveAnim.ARC, true)
	else:
		selector_interactive.start_selection(moves)
		selected_move = await selector_interactive.move_selected
		if GameManager.fast_move_enabled:
			selected_move.execute(General.MoveAnim.ARC, true)
		else:
			selected_move.execute(General.MoveAnim.LINE, false)
	
	await selected_move.execution_finished
	GameEvents.move_executed.emit(selected_move)
	
	if selected_move.wins:
		GameEvents.game_ended.emit()
	elif selected_move.gives_extra_turn:
		GameManager.advance_turn_same_player()
	else:
		GameManager.advance_turn_switch_player()


func _on_game_ended() -> void:
	selector_interactive.stop_selection()
