class_name Piece
extends Node


signal clicked(sender: Piece)


func enable_highlight():
	# TODO: implement
	pass


func disable_highlight():
	# TODO: implement
	pass 


func _on_input_selected():
	clicked.emit(self)
