class_name Piece
extends Node
## Piece of the game. Has selection and highlighting functionality. Also can be physically moved.


signal clicked(sender: Piece)


## Enables highlighting effects
func enable_highlight():
	# TODO: implement
	pass


## Disables highlighting effects
func disable_highlight():
	# TODO: implement
	pass 


## Moves the piece physically along the given [param movement_path].
func move(movement_path: Array[Vector3]):
	# TODO: implement
	pass


func _on_input_selected():
	clicked.emit(self)
