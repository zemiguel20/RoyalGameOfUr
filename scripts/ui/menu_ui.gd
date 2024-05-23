extends Node

@export var _singleplayer_scene: PackedScene = preload("res://scenes/game/singleplayer.tscn")
@export var _hotseat_scene: PackedScene = preload("res://scenes/game/hotseat.tscn")


func _on_singleplayer_pressed():
	_load_scene(_singleplayer_scene)


func _on_hotseat_pressed():
	_load_scene(_hotseat_scene)


func _on_quit_pressed():
	get_tree().quit()
	

func _load_scene(scene: PackedScene):
	get_tree().change_scene_to_packed(scene)
