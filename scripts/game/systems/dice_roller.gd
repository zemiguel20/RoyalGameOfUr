class_name DiceRoller extends Node3D
## Controls the process of rolling the dice and reading their values.
## Can have automatic throwing, or use input interaction.
## Player can click to roll or hold to shake them.
## Dice are moved to rolling zone first, as if grabbing them.


@export var _assigned_player: General.Player
@export var _impulse_strength: float = 0.2
@export var _automatic: bool = false
@export_range(0.0, 1.0, 0.1, "or_greater") var _show_result_duration: float = 0.5
@export_range(0.0, 1.0, 0.1, "or_greater") var _auto_delay_grab_dice: float = 0.5
@export_range(0.5, 1.0, 0.1) var _auto_min_shake_duration: float = 0.5
@export_range(1.0, 2.0, 0.1) var _auto_max_shake_duration: float = 2.0

var _place_spots: Array[Node3D] = []
var _throw_spots: Array[Node3D] = []
var _shake_sfx: AudioStreamPlayer3D
var _dice: Array[Die] = []


func _ready() -> void:
	_place_spots.assign(get_node(get_meta("placing_spots")).get_children())
	_throw_spots.assign(get_node(get_meta("throw_spots")).get_children())
	_shake_sfx = get_node(get_meta("shake_sfx"))
	
	GameEvents.roll_phase_started.connect(_start)


func _start(current_player: General.Player) -> void:
	if current_player != _assigned_player:
		return
	
	_dice.assign(EntityManager.get_dice())
	_dehighlight()
	await _place_dice()
	
	if _automatic:
		await get_tree().create_timer(_auto_delay_grab_dice).timeout
		_start_shaking()
		var shaking_duration = randf_range(_auto_min_shake_duration, _auto_max_shake_duration)
		await get_tree().create_timer(shaking_duration).timeout
		_stop_shaking()
	else:
		_highlight_selectable()
		_connect_input_signals()


# Moves the dice to the placing spots.
func _place_dice(skip_animation := false) -> void:
	# Move dice to random spots
	_place_spots.shuffle()
	for i in _dice.size():
		var die = _dice[i]
		var spot = _place_spots[i]
		
		var animation = General.MoveAnim.ARC if not skip_animation else General.MoveAnim.NONE
		die.move_anim.play(spot.global_position, animation)
	
	# Make sure dice are completely still
	for die in _dice:
		if die.move_anim.moving:
			await die.move_anim.movement_finished


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


func _highlight_hovered() -> void:
	for die in _dice:
		die.highlight.set_active(true).set_color(General.color_hovered)


func _highlight_selectable() -> void:
	for die in _dice:
		die.highlight.set_active(true).set_color(General.color_selectable)


func _highlight_result(total_value: int) -> void:
	if total_value == 0:
		for die in _dice:
			die.highlight.set_active(true).set_color(General.color_negative)
	else:
		for die in _dice:
			die.highlight.set_active(die.value == 1).set_color(General.color_positive)


func _dehighlight() -> void:
	for die in _dice:
		die.highlight.active = false


func _start_shaking() -> void:
	_shake_sfx.play()
	for die in _dice:
		die.model.visible = false


func _stop_shaking() -> void:
	_shake_sfx.stop()
	for die in _dice:
		die.model.visible = true
	_roll_dice()


func _roll_dice() -> void:
	_disconnect_input_signals()
	_dehighlight()
	var value = 0
	
	# Position and throw dice
	_throw_spots.shuffle()
	for i in _dice.size():
		var die = _dice[i]
		var throw_spot = _throw_spots[i]
		
		var start_position = throw_spot.global_position
		var start_rotation = General.get_random_rotation()
		var impulse = throw_spot.global_basis.y * _impulse_strength / 100
		die.roll(impulse, start_position, start_rotation)
	
	# wait roll finished
	for die in _dice:
		if die.rolling:
			await die.roll_finished
		value += die.value
	
	_highlight_result(value)
	
	await get_tree().create_timer(_show_result_duration).timeout
	
	GameEvents.rolled.emit(value)
	GameEvents.rolled_by_player.emit(value, _assigned_player)
