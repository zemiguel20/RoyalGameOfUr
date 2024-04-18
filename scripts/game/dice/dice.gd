## Dice controller. Controls the dice rolling animation and stores its value.
class_name Dice
extends Node

#region Signals
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
@export var _use_multiple_dice_areas: bool = true
#endregion

#region Onready Variables
## Sound effect played when the roll starts.
@onready var _roll_sfx: AudioStreamPlayer = $RollSFX
## Looping sound played while the dice are shaking.
@onready var _shake_sfx: AudioStreamPlayer = $ShakeSFX
## Reference point for the randomly generated 
@onready var _throwing_position: Node3D = $DiceArea_P1/ThrowingPosition_P1
## Throwing Position for Player 2. This one is only used when 
## [code] _use_multiple_dice_areas = true [/code]
@onready var _throwing_position_p2: Node3D = $DiceArea_P2/ThrowingPosition_P2
## Hitbox that makes it easier to click the dice.
@onready var _click_hitbox: Area3D = $DiceArea_P1/ClickHitbox_P1
## Hitbox that makes it easier to click the dice.
@onready var _click_hitbox_p2: Area3D = $DiceArea_P2/ClickHitbox_P2
## 3D Label displaying the outcome of the dice. Contains its own script with special effects.
@onready var _outcome_label: DiceOutcomeLabel = $DiceArea_P1/Label3D_Outcome_P1
#endregion

#region Regular Variables
## Current rolled value.
var value: int = 0 

## Array containing every die.
var _dice : Array[Die]
## Dictionary that maps _throwing_position and _throwing_position_p2 to a PlayerId.
var _dice_throwing_spots: Dictionary
## The throwing position that will be used for the current roll.
var _current_throwing_spot: Node3D
## The clicking hitbox that will be used for the current roll.
var _current_click_hitbox: Area3D
## Array that holds randomly generated positions that the dice will be thrown from.
var _positions: Array[Vector3]
## Indication if we should invert throwing direction of every die this roll.
## Used when player 2 throws for example.
var _invert_throwing_direction: bool
## The player that is performing the current roll.
## Used to decide which click hitbox to use.
var _current_player
## Boolean indicating if the dice are currently being shaken.
var _is_shaking: bool = false
## Number of dice that have finished their roll.
var _die_finish_count = 0
#endregion

func _ready() -> void:
	_initialize_dice()
	_cache_throwing_spots()
	disable_selection()
	
	
func _input(event: InputEvent) -> void:
	if not _roll_shaking_enabled:
		return
	
	# This function should not be in _on_die_input_event, 
	# since releasing the mouse can be done outside of the click hitboxes.
	if event is InputEventMouseButton and event.is_released():
		on_dice_release()
		
		
func on_roll_phase_started(player: General.Player):
	enable_selection()
	
	if _use_multiple_dice_areas:
		_current_throwing_spot = _dice_throwing_spots[player]
		_current_player = player
		_invert_throwing_direction = false if player == General.Player.ONE else true


## Enables selection and highlight effects
func enable_selection() -> void:
	_current_click_hitbox.input_ray_pickable = _use_hitbox_instead_of_dice_colliders
	for die in _dice:
		die.highlight()
		die.input_ray_pickable = true
		

## Disables selection and highlight effects
func disable_selection() -> void:
	_current_click_hitbox.input_ray_pickable = false
	for die in _dice:
		die.dehighlight()
		die.input_ray_pickable = false


## Plays the dice rolling animation and updates the value. Returns the rolled value.
func _roll() -> int:
	disable_selection()
	_outcome_label.visible = false	
	_roll_sfx.play()
	value = 0
	_die_finish_count = 0
	var die_positions = _get_die_throwing_positions()
	
	for i in _dice.size():
		_dice[i].roll(die_positions[i], _invert_throwing_direction)
	await roll_finished
	for die in _dice:
		die.outline_if_one()
	_set_click_hitbox()
	return value


func on_dice_click():
	if _is_shaking:
		return
	
	if _roll_shaking_enabled:
		_start_dice_shake()
	else:
		_roll()
	
	
func on_dice_release():
	if not _is_shaking:
		return

	_is_shaking = false
	_shake_sfx.stop()
	for die in _dice:
		die.visible = true
	_roll()
	
	
## Spawns the dice in a random position and connects signals
func _initialize_dice() -> void:
	for _i in _num_of_dice:
		var instance = _die_scene.instantiate() as Die
		add_child(instance)
		_dice.append(instance)
		
		instance.roll_finished.connect(_on_die_finished_rolling)
		instance.global_position = _get_die_spawning_position()
	
	if _use_hitbox_instead_of_dice_colliders:
		_click_hitbox.input_event.connect(_on_die_input_event)
		_click_hitbox_p2.input_event.connect(_on_die_input_event)
		_current_click_hitbox = _click_hitbox
	else:
		for die in _dice:
			die.input_event.connect(_on_die_input_event)
			
	
func _start_dice_shake():
	_is_shaking = true
	for die in _dice:
		die.visible = false
	_shake_sfx.play()
			
			
func _get_die_spawning_position():
	var locationX = randf_range(_max_spawning_position_offset.x, _max_spawning_position_offset.y)
	var locationZ = randf_range(_max_spawning_position_offset.x, _max_spawning_position_offset.y)
		
	return self.global_position + Vector3(locationX, 0, locationZ)
	
	
## Generate random positions to throw the dice from, while making sure that the dice always have a minimun offset of [param _minimal_dice_offset].
## If the function is not able to generate these positions, it will give a warning. 
func _get_die_throwing_positions() -> Array[Vector3]: 
	# Failsafe for if no combination is possible, then just try again
	var num_of_fails = 0
	var result = [] as Array[Vector3]
	
	while result.size() < _num_of_dice:
		if (num_of_fails >= 100):
			# If failed many times, try again from scratch and give a warning.
			push_warning("Dice positioning failed many times, consider tweaking '_minimal_dice_offset' or '_max_throwing_position_offset'")
			result.clear()
			num_of_fails = 0
			
		# Randomly decide the offset from the throwing position.
		var random_x = randf_range(-_max_throwing_position_offset, _max_throwing_position_offset)
		var random_z = randf_range(-_max_throwing_position_offset, _max_throwing_position_offset)
		var random_offset = Vector3(random_x, 0, random_z)
		var new_sample_position = _current_throwing_spot.global_position + random_offset
		
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
		
	return result
	
	
func _cache_throwing_spots():
	_current_throwing_spot = _throwing_position
	if (_use_multiple_dice_areas):
		_dice_throwing_spots = {}
		_dice_throwing_spots[General.Player.ONE] = _throwing_position
		_dice_throwing_spots[General.Player.TWO] = _throwing_position_p2
		

func _set_click_hitbox():
	if _use_multiple_dice_areas:
		_current_click_hitbox = _click_hitbox if _current_player == General.Player.ONE else _click_hitbox_p2


func _on_die_input_event(_camera, event : InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		on_dice_click()


func _on_die_finished_rolling(die_value: int):
	value += die_value
	_die_finish_count += 1
	die_stopped.emit(die_value)
	if (_num_of_dice <= _die_finish_count):
		roll_finished.emit(value)
