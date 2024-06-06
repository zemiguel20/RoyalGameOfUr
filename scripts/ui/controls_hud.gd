extends CanvasLayer

@onready var left_mouse_label = $Controls_Regular/LeftMouse/Interact as Label
@onready var right_mouse_label = $Controls_Regular/RightMouse/LookAround as Label
@onready var key_one_label = $Controls_Regular/OneKey/PieceMode as Label

func _on_game_started():
	visible = true
