## Dice controller. Controls the dice rolling animation and stores its value.
class_name Dice
extends Node

#region Signals
signal clicked
signal die_stopped(value: int) ## Emitted when a single die stops, with its value
signal roll_finished(value: int) ## Emitted when all dice finished, with the final value
#endregion

#region Export Variables
## The number of dice that will be used in the board game.
@export_range(0, 8) var _num_of_dice: int = 4
## The die that will be used in the board game.
@export var _die_scene: PackedScene
## When die are spawned in, they will have an offset from this object calculated as: 
## [code] randf_range(0, _max_spawning_position_offset) [/code]
@export var _max_spawning_position_offset := Vector2(-3, 3)
## When die are spawned in, they will have an offset from the selected throwing_position calculated as: 
## [code] randf_range(0, _max_throwing_position_offset) [/code]
@export var _max_throwing_position_offset := 1.7
## Minimum offset that dice should have with each other when the dice are thrown.
@export var _minimal_dice_offset := 0.5
## When enabled, Players and AI can hold the dice to shake them, delaying the throw and adding suspense.
@export var _roll_shaking_enabled: bool = false
## When [code] true [/code], player's can now click a hitbox (a Area3D which is a child of the dice_controller)
@export var _use_hitbox_instead_of_dice_colliders: bool
## If set to true, player 2 will throw the dice from the other side.
@export var _use_multiple_throwing_spots: bool = true
#endregion

#region Onready Variables
## Sound effect played w
@onready var _roll_sfx: AudioStreamPlayer = $RollSFX
@onready var _shake_sfx: AudioStreamPlayer = $ShakeSFX
## Reference 
@onready var _throwing_position: Node3D = $ThrowingPosition_P1
@onready var _throwing_position_p2: Node3D = $ThrowingPosition_P2
@onready var _click_hitbox: Area3D = $ClickHitbox
@onready var _outcome_label: Label3D = $Label3D_Outcome
#endregion

#region Regular Variables
## Current rolled value.
var value: int = 0 

## Array containing every die.
var _dice : Array[Die]
## Dictionary that maps _throwing_position and _throwing_position_p2 to a PlayerId.
var _dice_throwing_spots: Dictionary
## Array that holds randomly generated positions that the dice will be thrown from.
var _positions: Array[Vector3]
## Boolean indicating if the dice are currently being shaken.
var _is_shaking: bool = false
## Number of dice that have finished their roll.
var _die_finish_count = 0
#endregion

func _ready() -> void:
	_initialize_dice()
	disable_selection()
	
	if (_use_multiple_throwing_spots):
		_dice_throwing_spots = {}
		_dice_throwing_spots[General.PlayerID.ONE] = _throwing_position
		_dice_throwing_spots[General.PlayerID.TWO] = _throwing_position_p2
	
	
func _input(event: InputEvent) -> void:
	if not _roll_shaking_enabled:
		return
	
	# This function should not be in _on_die_input_event, 
	# since releasing the mouse can be done outside of the click hitboxes.
	if event is InputEventMouseButton and event.is_released():
		on_dice_release()


## Enables selection and highlight effects
func enable_selection() -> void:
	_click_hitbox.input_ray_pickable = _use_hitbox_instead_of_dice_colliders
	for die in _dice:
		die.highlight()
		die.input_ray_pickable = true
		

## Disables selection and highlight effects
func disable_selection() -> void:
	_click_hitbox.input_ray_pickable = false
	for die in _dice:
		die.dehighlight()
		die.input_ray_pickable = false


## Plays the dice rolling animation and updates the value. Returns the rolled value.
func roll(playerID: General.PlayerID = 0) -> int:
	disable_selection()
	_outcome_label.visible = false	
	_roll_sfx.play()
	value = 0
	_die_finish_count = 0
	var die_positions = _get_die_throwing_positions(playerID)
	
	for i in _dice.size():
		_dice[i].roll(die_positions[i], playerID)
	await roll_finished
	for die in _dice:
		die.outline_if_one()
	return value


func on_dice_click():
	if _is_shaking:
		return
	
	_outcome_label.visible = false	
	if _roll_shaking_enabled:
		start_dice_shake()
	else:
		_start_roll()
	
	
func on_dice_release():
	if not _is_shaking:
		return

	_is_shaking = false
	_shake_sfx.stop()
	for die in _dice:
		die.visible = true
	_start_roll()


## Function that emits a signal that the dice have been clicked. 
## Triggers the [RollPhase] to start the rolling of the dice.
func _start_roll():
	clicked.emit()
	
	
func start_dice_shake():
	_is_shaking = true
	for die in _dice:
		die.visible = false
	_shake_sfx.play()
	

## Spawns the dice in a random position and connects signals
func _initialize_dice() -> void:
	for _i in _num_of_dice:
		var instance = _die_scene.instantiate() as Die
		add_child(instance)
		_dice.append(instance)
		
		instance.setup(_throwing_position.global_position)
		instance.roll_finished.connect(_on_die_finished_rolling)
		
		instance.global_position = _get_die_spawning_position()
	
	if _use_hitbox_instead_of_dice_colliders:
		_click_hitbox.input_event.connect(_on_die_input_event)
	else:
		for die in _dice:
			die.input_event.connect(_on_die_input_event)
			
			
func _get_die_spawning_position():
	var locationX = randf_range(_max_spawning_position_offset.x, _max_spawning_position_offset.y)
	var locationZ = randf_range(_max_spawning_position_offset.x, _max_spawning_position_offset.y)
		
	return self.global_position + Vector3(locationX, 0, locationZ)
	
	
func _get_die_throwing_positions(playerID: General.PlayerID = 0) -> Array[Vector3]: 
	var result = [] as Array[Vector3]
	# Failsafe for if no combination is possible, then just try again
	var num_of_fails = 0
	
	var current_throwing_spots = _throwing_position if not _use_multiple_throwing_spots else _dice_throwing_spots[playerID]
	
	while result.size() < _num_of_dice:
		if (num_of_fails >= 100):
			# If failed many times, try again from scratch and give a warning.
			push_warning("Dice positioning failed many times, consider tweaking '_minimal_dice_offset' or '_max_throwing_position_offset'")
			result.clear()
			num_of_fails = 0
			
		var random_x = randf_range(-_max_throwing_position_offset, _max_throwing_position_offset)
		var random_z = randf_range(-_max_throwing_position_offset, _max_throwing_position_offset)
		var random_offset = Vector3(random_x, 0, random_z)
		var new_sample_position = current_throwing_spots.global_position + random_offset
		
		# Check if random position meets the requirements.
		var does_overlap = false
		for sample_position in result:
			if sample_position.distance_to(new_sample_position) < _minimal_dice_offset:
				does_overlap = true
		
		# Add to the result when the position does not overlap with other dice.
		if not does_overlap:
			result.append(new_sample_position)
		else:		
			num_of_fails += 1
		
	print("Found %s positions!" % result.size())
	print("Fails: ", num_of_fails)
	return result


func _on_die_input_event(_camera, event : InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		on_dice_click()


func _on_die_finished_rolling(die_value: int):
	value += die_value
	_die_finish_count += 1
	die_stopped.emit(die_value)
	_outcome_label.text = "%s" % value
	if (_num_of_dice <= _die_finish_count):
		roll_finished.emit(value)
		
