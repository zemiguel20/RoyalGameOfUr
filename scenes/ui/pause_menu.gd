class_name PauseMenu
extends Control

## Only load this scene when we need it, to prevent an infinite loop of scenes preloading each other.
@export var _main_menu: PackedScene = load("res://scenes/game/main_menu.tscn")
var _is_paused := false

func toggle():
	_is_paused = !_is_paused
	visible = _is_paused
	Engine.time_scale = 0 if _is_paused else 1


func _load_scene(scene: PackedScene):
	get_tree().change_scene_to_packed(scene)
	

func _on_continue_pressed():
	toggle()


func _on_return_pressed():
	toggle()
	_load_scene(_main_menu)	


func _on_restart_pressed():
	toggle()	
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().quit()
