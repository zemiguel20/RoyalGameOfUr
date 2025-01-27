class_name RollController
extends Node
## Abstract class for roll controllers. Contains common shaking and dice toss behaviour,
## to be used by the concrete classes.


signal rolled(result: int)
signal shake_started
signal shake_stopped
signal dice_tossed

var _dice: Array[Die]
var _dice_zone: DiceZone
var _last_rolled_value: int = 0
var _shaking_sfx: AudioStreamPlayer


func _ready() -> void:
	_shaking_sfx = AudioStreamPlayer.new()
	add_child(_shaking_sfx)
	_shaking_sfx.stream = preload("res://audio/sfx_mastered/dice-shaking-loop.mp3")


func init(dice: Array[Die], dice_zone: DiceZone) -> void:
	_dice = dice.duplicate()
	_dice_zone = dice_zone


func start_roll() -> void:
	await _place()
	_start_toss_procedure()


func _place() -> void:
	var placing_points = _dice_zone.get_placing_points_global_randomized()
	
	for i in _dice.size():
		var die = _dice[i]
		var point = placing_points[i]
		die.place(point)
	# Dice are moved simultaneously, so only need to await the signal of one of them
	await (_dice.front() as Die).placed


## Abstract method. Defines how to toss the dice (e.g. use input to shake and toss).
func _start_toss_procedure() -> void:
	push_warning("Using abstract method. Implement method in concrete class.")


func _start_shaking() -> void:
	for die in _dice:
		die.visible = false
	_shaking_sfx.play()
	shake_started.emit()


func _stop_shaking() -> void:
	_shaking_sfx.stop()
	shake_stopped.emit()
	_toss_dice()
	
	# NOTE: The actual start of the roll is tied to the physics frame rate.
	# The dice should only be turned visible again after the toss has been processed, 
	# otherwise they can be seen teleporting from the table to the throwing points.
	await get_tree().create_timer(0.1).timeout
	for die in _dice:
		die.visible = true


func _toss_dice() -> void:
	var throw_points = _dice_zone.get_throw_points_shuffled()
	for i in _dice.size():
		var die = _dice[i]
		var impulse = 0.003 * throw_points[i].direction
		var position = throw_points[i].global_position
		die.roll(impulse, position)
	
	dice_tossed.emit()
	
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


## Highlights the dice with the appropriate color for a positive or negative result.
## To be called externally after the result is processed.
func highlight_result(positive: bool) -> void:
	var type = General.HighlightType.POSITIVE if positive else General.HighlightType.NEGATIVE
	var highlight_only_ones: bool = positive or _last_rolled_value > 0
	for die in _dice:
		if highlight_only_ones == false or die.last_rolled_value == 1:
			die.enable_highlight(General.get_highlight_color(type))


func clear_highlight() -> void:
	for die in _dice:
		die.disable_highlight()
