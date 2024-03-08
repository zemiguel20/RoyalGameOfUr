class_name Dice
extends Node
## Dice controller. Controls the dice rolling animation and stores its value.


signal clicked
signal die_stopped(value: int) # Emitted when a single die stops, with its value
signal roll_finished(value: int) # Emitted when all dice finished, with final value


@export_range(0, 8) var _num_of_dice: int = 4
@export var _roll_shaking_enabled: bool = false
@export var _die_scene: PackedScene
@export var _spawning_range := Vector2(-3, 3)
@export var _use_hitbox_instead_of_dice_colliders: bool



## Current rolled value.
var value: int = 0 

var _dice : Array[Die]
var _is_shaking: bool = false
var _die_finish_count = 0


@onready var _roll_sfx: AudioStreamPlayer = $RollSFX
@onready var _shake_sfx: AudioStreamPlayer = $ShakeSFX
@onready var _throwing_position: Node3D = $Node3D_ThrowingPosition
@onready var _click_hitbox: Area3D = $ClickHitbox


func _ready() -> void:
	_initialize_dice()
	disable_selection()
	
	
func _input(event: InputEvent) -> void:
	if (not _roll_shaking_enabled):
		return
	
	# This function should not be in _on_die_input_event, 
	# since releasing the mouse can be done outside of the click hitboxes.
	if (event is InputEventMouseButton and event.is_released()):
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
func roll() -> int:
	disable_selection()
	_roll_sfx.play()
	value = 0
	_die_finish_count = 0
	for die in _dice:
		die.roll()
	while _die_finish_count < _num_of_dice:
		await get_tree().create_timer(0.5).timeout
	roll_finished.emit(value)
	return value


func on_dice_click():
	if _roll_shaking_enabled and not _is_shaking:
		start_dice_shake()
	else:
		_start_roll()
	
	
func on_dice_release():
	if (not _is_shaking):
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
		
		# TODO: Make this editable as well, but this should be handled by a Placer script.
		# This script will then also make sure that the dice do not overlapped.
		var locationX = randf_range(_spawning_range.x, _spawning_range.y)
		var locationZ = randf_range(_spawning_range.x, _spawning_range.y)
		instance.global_position = self.global_position + Vector3(locationX, 0, locationZ)
	
	if (_use_hitbox_instead_of_dice_colliders):
		_click_hitbox.input_event.connect(_on_die_input_event)
	else:
		for die in _dice:
			die.input_event.connect(_on_die_input_event)


func _on_die_input_event(_camera, event : InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		on_dice_click()


func _on_die_finished_rolling(die_value: int):
	value += die_value
	_die_finish_count += 1
	die_stopped.emit(die_value)
