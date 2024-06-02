class_name MovePicker extends Node
## Controls the process of picking a move from a list of possible moves.


signal move_executed(move: GameMove)

var selector # Can be of different types

var selected_move: GameMove


func _ready() -> void:
	for node in get_children():
		if node is AIGameMoveSelector or node is InteractiveGameMoveSelector:
			selector = node
	
	if not selector:
		push_error("MovePicker: Could not find selector child node.")


## Starts the selection system for the given list of [param moves].
func start(moves: Array[GameMove]) -> void:
	var animation = General.MoveAnim.NONE
	
	if selector is AIGameMoveSelector:
		selector.start_selection(moves)
		selected_move = await selector.move_selected
		selected_move.execute(General.MoveAnim.ARC, true)
		await selected_move.execution_finished
		move_executed.emit(selected_move)
	
	if selector is InteractiveGameMoveSelector:
		selector.start_selection(moves)
		selected_move = await selector.move_selected
		selected_move.execute(General.MoveAnim.LINE)
		await selected_move.execution_finished
		move_executed.emit(selected_move)
	
	# Execute move
	
