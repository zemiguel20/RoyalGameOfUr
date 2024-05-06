extends Node

var moveSystems: Array[MoveSystem]

func _ready():
	moveSystems.append(get_node("MoveSysClick"))
	moveSystems.append(get_node("MoveSysDDHold"))
	moveSystems.append(get_node("MoveSysDDClick"))

func _input(event):
	if Input.is_key_pressed(KEY_1):
		print("Switched to movement system: Single click")
		moveSystems[0].start_selection() ###
		moveSystems[1].end_selection()
		moveSystems[2].end_selection()
	if Input.is_key_pressed(KEY_2):
		print("Switched to movement system: Drag & Drop (Hold)")
		moveSystems[0].end_selection()
		moveSystems[1].start_selection() ###
		moveSystems[2].end_selection()
	if Input.is_key_pressed(KEY_3):
		print("Switched to movement system: Drag & Drop (Click)")
		moveSystems[0].end_selection()
		moveSystems[1].end_selection()
		moveSystems[2].start_selection() ###
