extends Node

var _move_systems: Array[MoveSystem]


func _ready():
	_move_systems.append(get_node("MoveSysClick"))
	_move_systems.append(get_node("MoveSysDDHold"))
	_move_systems.append(get_node("MoveSysDDClick"))


func _input(event):
	if Input.is_key_pressed(KEY_1):
		print("Switched to movement system: Single click")
		_move_systems[0].start_selection()
		_move_systems[1].end_selection()
		_move_systems[2].end_selection()
	if Input.is_key_pressed(KEY_2):
		print("Switched to movement system: Drag & Drop (Hold)")
		_move_systems[0].end_selection()
		_move_systems[1].start_selection()
		_move_systems[2].end_selection()
	if Input.is_key_pressed(KEY_3):
		print("Switched to movement system: Drag & Drop (Click)")
		_move_systems[0].end_selection()
		_move_systems[1].end_selection()
		_move_systems[2].start_selection()
