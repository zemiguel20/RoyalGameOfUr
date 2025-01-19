class_name Dice
extends Node
## Manages a group of dice.


signal rolled(value: int) ## Emitted after rolling the dice.

const DIE_PREFAB: PackedScene = preload("res://scenes/game/entities/d4_die.tscn")

var _dice: Array[Die] = []

# This cached reference is for the interactive rolling,
# to avoid passing it down through the callbacks
var _throw_points: Array[DiceZone.ThrowPoint]

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
	# Cached to use later for the roll itself
	_throw_points = dice_zone.get_throw_points_shuffled()
	
	_deactivate_dice_interaction()
	await _place(dice_zone)
	
	for die in _dice:
		die.set_input_reading(true)
		
		
		if not die.clicked.is_connected(_roll):
			die.clicked.connect(_roll)
		if not die.hold_started.is_connected(_start_shaking):
			die.hold_started.connect(_start_shaking)
		if not die.hold_stopped.is_connected(_stop_shaking):
			die.hold_stopped.connect(_stop_shaking)
		if not die.mouse_entered.is_connected(_highlight_hovered):
			die.mouse_entered.connect(_highlight_hovered)
		if not die.mouse_exited.is_connected(_highlight_selectable):
			die.mouse_exited.connect(_highlight_selectable)
		
		die.enable_highlight(General.get_highlight_color(General.HighlightType.SELECTABLE))


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
		die.enable_highlight(General.get_highlight_color(General.HighlightType.SELECTABLE))


func _highlight_hovered() -> void:
	for die in _dice:
		die.enable_highlight(General.get_highlight_color(General.HighlightType.HOVERED))


func _start_shaking() -> void:
	for die in _dice:
		die.visible = false
	
	_shaking_sfx.play()


func _stop_shaking() -> void:
	_shaking_sfx.stop()
	
	_roll()


func _roll() -> void:
	_deactivate_dice_interaction()
	
	for i in _dice.size():
		var die = _dice[i]
		var impulse = 0.003 * _throw_points[i].direction
		var position = _throw_points[i].global_position
		die.roll(impulse, position)
	
	# The actual start of the roll is tied to the physics frame rate.
	# In case the dice are shaken (turned invisible), they should only be turned visible
	# again after the roll has been processed, otherwise they can be seen teleporting
	# from the table to the throwing points.
	await get_tree().create_timer(0.1).timeout
	for die in _dice:
		die.visible = true
	
	# This guarantees a slight pause in case the dice settle fast.
	await get_tree().create_timer(1).timeout
	
	var result := 0
	
	for die in _dice:
		if die.is_rolling:
			result += await die.rolled
		else:
			result += die.last_rolled_value
	
	# Visual count
	if not Settings.fast_mode:
		for die in _dice:
			if die.last_rolled_value > 0:
				die.enable_highlight(General.get_highlight_color(General.HighlightType.NEUTRAL))
				await get_tree().create_timer(0.2).timeout
	
	rolled.emit(result)


func _deactivate_dice_interaction() -> void:
	for die in _dice:
		die.set_input_reading(false)
		
		if die.clicked.is_connected(_roll):
			die.clicked.disconnect(_roll)
		if die.hold_started.is_connected(_start_shaking):
			die.hold_started.disconnect(_start_shaking)
		if die.hold_stopped.is_connected(_stop_shaking):
			die.hold_stopped.disconnect(_stop_shaking)
		if die.mouse_entered.is_connected(_highlight_hovered):
			die.mouse_entered.disconnect(_highlight_hovered)
		if die.mouse_exited.is_connected(_highlight_selectable):
			die.mouse_exited.disconnect(_highlight_selectable)
		
		die.disable_highlight()


## Highlights the dice with the appropriate color for a positive or negative result.
## The [param only_ones] flag serves to highlight only the dice with value 1.
## Called externally depending on the processing of the result.
func highlight_result(positive: bool, only_ones: bool) -> void:
	var type = General.HighlightType.POSITIVE if positive else General.HighlightType.NEGATIVE
	
	for die in _dice:
		if only_ones == false or die.last_rolled_value == 1:
			die.enable_highlight(General.get_highlight_color(type))
