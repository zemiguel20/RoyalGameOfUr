class_name Dice
extends Node
## Manages a group of dice.


signal rolled(value: int) ## Emitted after rolling the dice.

const DIE_PREFAB: PackedScene = preload("res://scenes/game/entities/d4_die.tscn")

var _dice: Array[Die] = []

@onready var _shaking_sfx: AudioStreamPlayer = $ShakingSFX


## Spawns a number of dice in the given dice zone.
func init(num_dice: int, spawn: DiceZone) -> void:
	for die in _dice:
		die.queue_free()
	_dice.clear()
	
	var spawn_points = spawn.get_placing_points_global_randomized()
	for i in num_dice:
		var die = DIE_PREFAB.instantiate()
		add_child(die)
		_dice.append(die)
		die.global_position = spawn_points[i]


## Starts the interactive roll procedure. Emits [signal rolled] by the end of the roll.
func start_roll_interactive(dice_zone: DiceZone) -> void:
	_deactivate_dice_interaction()
	await _place(dice_zone)
	
	for die in _dice:
		die.set_input_reading(true)
		
		die.clicked.connect(_roll)
		die.hold_started.connect(_start_shaking)
		die.hold_stopped.connect(_stop_shaking)
		die.mouse_entered.connect(_highlight_hovered)
		die.mouse_exited.connect(_highlight_selectable)
		
		die.set_highlight(Die.HighlightType.SELECTABLE)


func _place(dice_zone: DiceZone) -> void:
	var placing_points = dice_zone.get_placing_points_global_randomized()
	
	for i in _dice.size():
		var die = _dice[i]
		var point = placing_points[i]
		die.place(point)
	# Dice are moved simultaneously, so only need to await the signal of one of them
	await (_dice.front() as Die).placed


func _highlight_selectable() -> void:
	for die in _dice:
		die.set_highlight(Die.HighlightType.SELECTABLE)


func _highlight_hovered() -> void:
	for die in _dice:
		die.set_highlight(Die.HighlightType.HOVERED)


func _start_shaking() -> void:
	for die in _dice:
		die.visible = false
	
	_shaking_sfx.play()


func _stop_shaking() -> void:
	for die in _dice:
		die.visible = true
	
	_shaking_sfx.stop()
	
	_roll()


func _roll() -> void:
	_deactivate_dice_interaction()
	
	# TODO: implement rolling
	push_error("NOT IMPLEMENTED")
	await get_tree().create_timer(0.1).timeout
	rolled.emit(randi_range(0, 4))


func _deactivate_dice_interaction() -> void:
	for die in _dice:
		die.set_input_reading(false)
		
		die.clicked.disconnect(_roll)
		die.hold_started.disconnect(_start_shaking)
		die.hold_stopped.disconnect(_stop_shaking)
		die.mouse_entered.disconnect(_highlight_hovered)
		die.mouse_exited.disconnect(_highlight_selectable)
		
		die.set_highlight(Die.HighlightType.NONE)


## Highlights the dice with the appropriate color for a positive or negative result.
## The [param only_ones] flag serves to highlight only the dice with value 1.
## Called externally depending on the processing of the result.
func highlight_result(positive: bool, only_ones: bool) -> void:
	# TODO: implement
	push_error("NOT IMPLEMENTED")
