class_name DiceRoller extends Node3D
## Controls the process of rolling the dice and reading their values.
## Can have automatic throwing, or use input interaction.
## Player can click to roll or hold to shake them.
## Dice are moved to rolling zone first, as if grabbing them.


@export var assigned_player: General.Player
@export var impulse_strength: float = 0.2
@export_range(0.0, 1.0, 0.1, "or_greater") var show_result_duration: float = 0.5
@export_range(0.0, 1.0, 0.1, "or_greater") var delay_after_roll: float = 0.5
@export_range(0.0, 1.0, 0.1, "or_greater") var auto_delay_grab_dice: float = 0.5
@export_range(0.5, 1.0, 0.1) var auto_min_shake_duration: float = 0.5
@export_range(1.0, 2.0, 0.1) var auto_max_shake_duration: float = 2.0
@export var color_dice_selectable := Color.MEDIUM_AQUAMARINE
@export var color_dice_hovered := Color.AQUAMARINE
@export var color_dice_positive_result := Color.LIME_GREEN
@export var color_dice_negative_result := Color.CRIMSON

var place_spots: Array[Node3D] = []
var throw_spots: Array[Node3D] = []
var shake_sfx: AudioStreamPlayer3D
var dice: Array[Die] = []
var automatic: bool = false

var no_moves_flag: bool = false


func _ready() -> void:
	place_spots.assign(get_node(get_meta("placing_spots")).get_children())
	throw_spots.assign(get_node(get_meta("throw_spots")).get_children())
	shake_sfx = get_node(get_meta("shake_sfx"))
	
	GameEvents.new_turn_started.connect(_on_new_turn_started)
	GameEvents.no_moves.connect(_on_no_moves)


func _on_new_turn_started() -> void:
	no_moves_flag = false
	
	# Do nothing if not assigned player's turn
	if GameState.current_player != assigned_player:
		return
	
	# Set second player automatic in singleplayer mode
	automatic = not Settings.is_hotseat_mode and GameState.current_player == General.Player.TWO
	
	dice.assign(EntityManager.get_dice())
	_dehighlight_dice()
	await _place_dice()
	
	if automatic:
		await get_tree().create_timer(auto_delay_grab_dice).timeout
		_start_shaking()
		var shaking_duration = randf_range(auto_min_shake_duration, auto_max_shake_duration)
		await get_tree().create_timer(shaking_duration).timeout
		_stop_shaking()
	else:
		_highlight_dice_selectable()
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


func _connect_input_signals() -> void:
	for die in dice:
		if not die.input.hovered.is_connected(_highlight_dice_hovered):
			die.input.hovered.connect(_highlight_dice_hovered)
		if not die.input.dehovered.is_connected(_highlight_dice_selectable):
			die.input.dehovered.connect(_highlight_dice_selectable)
		if not die.input.hold_started.is_connected(_start_shaking):
			die.input.hold_started.connect(_start_shaking)
		if not die.input.hold_stopped.is_connected(_stop_shaking):
			die.input.hold_stopped.connect(_stop_shaking)
		if not die.input.clicked.is_connected(_roll_dice):
			die.input.clicked.connect(_roll_dice)


func _disconnect_input_signals() -> void:
	for die in dice:
		if die.input.hovered.is_connected(_highlight_dice_hovered):
			die.input.hovered.disconnect(_highlight_dice_hovered)
		if die.input.dehovered.is_connected(_highlight_dice_selectable):
			die.input.dehovered.disconnect(_highlight_dice_selectable)
		if die.input.hold_started.is_connected(_start_shaking):
			die.input.hold_started.disconnect(_start_shaking)
		if die.input.hold_stopped.is_connected(_stop_shaking):
			die.input.hold_stopped.disconnect(_stop_shaking)
		if die.input.clicked.is_connected(_roll_dice):
			die.input.clicked.disconnect(_roll_dice)


func _highlight_dice_selectable() -> void:
	for die in dice:
		die.highlight.set_active(true).set_color(color_dice_selectable)


func _highlight_dice_hovered() -> void:
	for die in dice:
		die.highlight.set_active(true).set_color(color_dice_hovered)


func _highlight_dice_result(total_value: int) -> void:
	if total_value == 0:
		for die in dice:
			die.highlight.set_active(true).set_color(color_dice_negative_result)
	else:
		for die in dice:
			# Only highlight dice that rolled 1
			die.highlight.active = die.value == 1
			die.highlight.color = color_dice_negative_result if no_moves_flag \
				else color_dice_positive_result


func _dehighlight_dice() -> void:
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
	_dehighlight_dice()
	var value = 0
	
	# Position and throw dice
	throw_spots.shuffle()
	for i in dice.size():
		var die = dice[i]
		var throw_spot = throw_spots[i]
		
		var start_position = throw_spot.global_position
		var start_rotation = General.get_random_rotation()
		var impulse = throw_spot.global_basis.y * impulse_strength / 100
		die.roll(impulse, start_position, start_rotation)
	
	# wait roll finished
	for die in dice:
		if die.rolling:
			await die.roll_finished
		value += die.value
	
	await get_tree().create_timer(delay_after_roll).timeout
	
	GameEvents.rolled.emit(value)
	
	_highlight_dice_result(value)
	await get_tree().create_timer(show_result_duration).timeout
	
	GameEvents.roll_sequence_finished.emit()


func _on_no_moves() -> void:
	no_moves_flag = true
