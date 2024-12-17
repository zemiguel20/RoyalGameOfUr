class_name Dice
extends Node
## Manages a group of dice.


const DIE_PREFAB: PackedScene = preload("res://scenes/game/entities/d4_die.tscn")

var dice: Array[Die] = []


func init(num_dice: int, spawn: DiceZone) -> void:
	var spawn_points = spawn.get_placing_points_global_randomized()
	for i in num_dice:
		var die = DIE_PREFAB.instantiate()
		add_child(die)
		die.global_position = spawn_points[i]
