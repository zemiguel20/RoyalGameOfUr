class_name DiceRoller extends Node3D
## Controls the process of rolling the dice and reading their values.
## Can have automatic throwing, or use input interaction.
## Player can click to roll or hold to shake them.
## Dice are moved to rolling zone first, as if grabbing them.


signal dice_placed

@export var assigned_player: General.Player
@export var automatic: bool = false
@export var impulse_strength: float = 0.01 

var place_spots: Array[Node3D] = []
var throw_spots: Array[Node3D] = []
var shake_sfx: AudioStreamPlayer3D

var dice: Array[Die] = []

func _ready() -> void:
	place_spots.assign(get_node(get_meta("placing_spots")).get_children())
	throw_spots.assign(get_node(get_meta("throw_spots")).get_children())
	shake_sfx = get_node(get_meta("shake_sfx"))
	
	GameEvents.roll_phase_started.connect(start)


func start(current_player: General.Player) -> void:
	if current_player != assigned_player:
		return
	
	dice.assign(EntityManager.get_dice())
	_dehighlight()
	_place_dice()
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


# Moves the dice to the placing spots.
func _place_dice(skip_animation := false) -> void:
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

func _connect_input_signals() -> void:
	for die in dice:
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
	for die in dice:
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
	for die in dice:
		die.highlight.set_active(true).set_color(General.color_hovered)


func _highlight_selectable() -> void:
	for die in dice:
		die.highlight.set_active(true).set_color(General.color_selectable)


func _highlight_result() -> void:
	for die in dice:
		die.highlight.active = true
		die.highlight.color = General.color_positive if die.value == 1 else General.color_negative


func _dehighlight() -> void:
	for die in dice:
		die.highlight.active = false


func _start_shaking() -> void:
	shake_sfx.play()
	for die in dice:
		die.model.visible = false


func _stop_shaking() -> void:
	shake_sfx.stop()
	for die in dice:
		die.model.visible = true
	_roll_dice()


func _roll_dice() -> void:
	_disconnect_input_signals()
	_dehighlight()
	var value = 0
	
	# Position and throw dice
	throw_spots.shuffle()
	for i in dice.size():
		var die = dice[i]
		var throw_spot = throw_spots[i]
		
		var start_position = throw_spot.global_position
		var start_rotation = General.get_random_rotation()
		var impulse = throw_spot.global_basis.y * impulse_strength
		die.roll(impulse, start_position, start_rotation)
	
	# wait roll finished
	for die in dice:
		if die.rolling:
			await die.roll_finished
		value += die.value
	
	_highlight_result()
	
	GameEvents.rolled.emit(value)
