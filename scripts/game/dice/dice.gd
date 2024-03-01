class_name Dice
extends Node
## Dice controller. Controls the dice rolling animation and stores its value.


signal clicked
signal die_stopped(value: int) # Emitted when a single die stops, with its value
signal roll_finished(value: int) # Emitted when all dice finished, with final value

@export_range(0, 8) var _num_of_dice: int = 4
@export var _roll_shaking_enabled: bool = false
@export var _use_hitbox_instead_of_dice_colliders: bool
# NOTE We could also base this off of the size of the _click_hitbox? 
@export var _spawning_range := Vector2(-3, 3)

var value: int = 0 ## Current rolled value.

var _die_scene: PackedScene = preload("res://scenes/game/dice/d4.tscn")
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
	enable_selection()
	roll_finished.emit(value)
	return value


func _initialize_dice() -> void:
	for _i in _num_of_dice:
		var instance = _die_scene.instantiate() as Die
		add_child(instance)
		instance.setup(_throwing_position.global_position)
		_dice.append(instance)
		instance.roll_finished.connect(_on_die_finished_rolling)
		# TODO: Make this editable as well, but this should be handled by a Placer script.
		# This script will then also make sure that the dice do not overlapped.
		var locationX = randf_range(_spawning_range.x, _spawning_range.y)
		var locationZ = randf_range(_spawning_range.x, _spawning_range.y)
		instance.global_position = self.global_position + Vector3(locationX, 0, locationZ)
	
	if (_use_hitbox_instead_of_dice_colliders):
		_click_hitbox.input_event.connect(_on_die_input_event)
		_click_hitbox.input_ray_pickable = true
	else:
		for die in _dice:
			die.input_event.connect(_on_die_input_event)


func _on_die_input_event(_camera, event : InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if _roll_shaking_enabled and not _is_shaking:
			_is_shaking = true
			for die in _dice:
				die.visible = false
			_shake_sfx.play()
		else:
			clicked.emit()
	
	if _is_shaking and event is InputEventMouseButton and event.is_released():
		_is_shaking = false
		_shake_sfx.stop()
		for die in _dice:
			die.visible = true
		clicked.emit()


func _on_die_finished_rolling(die_value: int):
	value += die_value
	_die_finish_count += 1
	die_stopped.emit(die_value)
