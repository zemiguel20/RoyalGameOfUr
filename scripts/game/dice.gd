class_name Dice
extends Node
## Manages a group of dice.


signal placed ## Emitted by [method place].
signal rolled(value: int) ## Emitted after rolling the dice.

const DIE_PREFAB: PackedScene = preload("res://scenes/game/entities/d4_die.tscn")

var _dice: Array[Die] = []


## Spawns a number of dice in the given dice zone.
func init(num_dice: int, spawn: DiceZone) -> void:
	var spawn_points = spawn.get_placing_points_global_randomized()
	for i in num_dice:
		var die = DIE_PREFAB.instantiate()
		add_child(die)
		_dice.append(die)
		die.global_position = spawn_points[i]


## Coroutine that places the dice in the given dice zone. Emits [signal placed].
func place(dice_zone: DiceZone) -> void:
	var placing_points = dice_zone.get_placing_points_global_randomized()
	
	for i in _dice.size():
		var die = _dice[i]
		var point = placing_points[i]
		die.place(point)
	# Dice are moved simultaneously, so only need to await the signal of one of them
	await (_dice.front() as Die).placed
	
	placed.emit()


## Starts the interactive roll procedure. Emits [signal rolled] by the end of the roll.
func start_roll_interactive() -> void:
	# TODO: implement
	push_error("NOT IMPLEMENTED")
	await get_tree().create_timer(0.1).timeout
	rolled.emit(randi_range(0, 4))


## Highlights the dice with the appropriate color for a positive or negative result.
## The [param only_ones] flag serves to highlight only the dice with value 1.
func highlight_result(positive: bool, only_ones: bool) -> void:
	# TODO: implement
	push_error("NOT IMPLEMENTED")
