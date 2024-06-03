class_name DiceRoller extends Node3D
## Controls the process of rolling the dice and reading their values.
## Can have automatic throwing, or use input interaction.
## Player can click to roll or hold to shake them.
## Allows moving dice to rolling zone, as if grabbing them.


signal roll_finished(value: int)
signal dice_placed

@export var automatic: bool = false

var place_spots: Array[Node3D] = []
var throw_spots: Array[Node3D] = []
var shake_sfx: AudioStreamPlayer3D

var last_rolled_value := 0

var _dice: Array[Die] = []

func _ready() -> void:
	place_spots.assign(get_node(get_meta("placing_spots")).get_children())
	throw_spots.assign(get_node(get_meta("throw_spots")).get_children())
	shake_sfx = get_node(get_meta("shake_sfx"))


func start(dice: Array[Die]) -> void:
	_dice.assign(dice)
	_dehighlight()
	place_dice(dice)
	await dice_placed
	
	if automatic:
		await get_tree().create_timer(0.5).timeout
		_start_shaking()
		var shaking_duration = randf_range(0.5, 2.0)
		await get_tree().create_timer(shaking_duration).timeout
		_stop_shaking()
	else:
		_highlight_selectable()
		_connect_input_signals()


## Moves the dice to the placing spots.
## Can be used to animate transfering the dice between players.
func place_dice(dice: Array[Die], skip_animation := false) -> void:
	# Move dice to random spots
	place_spots.shuffle()
	for i in dice.size():
		var die = dice[i]
		var spot = place_spots[i]
		
		var animation = General.MoveAnim.ARC if not skip_animation else General.MoveAnim.NONE
		die.move_anim.play(spot.global_position, animation)
	
	# Make sure dice are completely still
	for die in dice:
		if die.move_anim.moving:
			await die.move_anim.movement_finished
	
	dice_placed.emit()


func _highlight_hovered() -> void:
	for die in _dice:
		die.highlight.set_active(true).set_color(General.color_hovered)


func _highlight_selectable() -> void:
	for die in _dice:
		die.highlight.set_active(true).set_color(General.color_selectable)


func _highlight_result() -> void:
	for die in _dice:
		die.highlight.active = true
		die.highlight.color = General.color_positive if die.value == 1 else General.color_negative


func _dehighlight() -> void:
	for die in _dice:
		die.highlight.active = false


func _start_shaking() -> void:
	shake_sfx.play()
	for die in _dice:
		die.model.visible = false


func _stop_shaking() -> void:
	shake_sfx.stop()
	for die in _dice:
		die.model.visible = true
	_roll_dice()


func _roll_dice() -> void:
	_disconnect_input_signals()
	_dehighlight()
	last_rolled_value = 0
	
	# Position and throw dice
	throw_spots.shuffle()
	for i in _dice.size():
		var die = _dice[i]
		var throw_spot = throw_spots[i]
		
		var start_position = throw_spot.global_position
		var start_rotation = General.get_random_rotation()
		var impulse = throw_spot.global_basis.y * 0.01
		die.roll(impulse, start_position, start_rotation)
	
	# wait roll finished
	for die in _dice:
		if die.rolling:
			await die.roll_finished
		last_rolled_value += die.value
	
	_highlight_result()
	
	roll_finished.emit(last_rolled_value)


func _connect_input_signals() -> void:
	for die in _dice:
		if not die.input.hovered.is_connected(_highlight_hovered):
			die.input.hovered.connect(_highlight_hovered)
		if not die.input.dehovered.is_connected(_highlight_selectable):
			die.input.dehovered.connect(_highlight_selectable)
		if not die.input.hold_started.is_connected(_start_shaking):
			die.input.hold_started.connect(_start_shaking)
		if not die.input.hold_stopped.is_connected(_stop_shaking):
			die.input.hold_stopped.connect(_stop_shaking)
		if not die.input.clicked.is_connected(_roll_dice):
			die.input.clicked.connect(_roll_dice)


func _disconnect_input_signals() -> void:
	for die in _dice:
		if die.input.hovered.is_connected(_highlight_hovered):
			die.input.hovered.disconnect(_highlight_hovered)
		if die.input.dehovered.is_connected(_highlight_selectable):
			die.input.dehovered.disconnect(_highlight_selectable)
		if die.input.hold_started.is_connected(_start_shaking):
			die.input.hold_started.disconnect(_start_shaking)
		if die.input.hold_stopped.is_connected(_stop_shaking):
			die.input.hold_stopped.disconnect(_stop_shaking)
		if die.input.clicked.is_connected(_roll_dice):
			die.input.clicked.disconnect(_roll_dice)
