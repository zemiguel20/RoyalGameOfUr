class_name Dice
extends Node
## Dice controller. Controls the dice rolling animation and stores its value.


signal clicked

@export_range(0, 8) var _num_of_dice: int = 4
@export var _roll_shaking_enabled: bool = false
@export var _use_hitbox_instead_of_dice_colliders : bool
@export var _click_hitbox : CollisionObject3D

var value: int = 0 ## Current rolled value.

var _die_scene: PackedScene = preload("res://scenes/gameplay/test_die_d4.tscn")
var _dice : Array[Die]
var _is_shaking: bool = false
@onready var _roll_sfx: AudioStreamPlayer = $RollSFX
@onready var _shake_sfx: AudioStreamPlayer = $ShakeSFX


func _ready() -> void:
	_initialize_dice()


## Enables selection and highlight effects
func enable_selection() -> void:
	# TODO: implement
	pass


## Disables selection and highlight effects
func disable_selection() -> void:
	# TODO: implement
	pass


## Plays the dice rolling animation and updates the value. Returns the rolled value.
func roll() -> int:
	disable_selection()
	_roll_sfx.play()
	for die in _dice:
		die.roll()
	value = 0
	for die in _dice:
		value += await die.roll_finished
	enable_selection()
	return value


func _initialize_dice() -> void:
	for a in _num_of_dice:
		var instance = _die_scene.instantiate() as Die
		add_child(instance)
		_dice.append(instance)
		# TODO: Make this editable as well, but this should be handled by a Placer script.
		# This script will then also make sure that the dice do not overlapped.
		var locationX = randf_range(-2.5, 2.5)
		var locationZ = randf_range(-2.5, 2.5)
		instance.global_position = Vector3(locationX, 0, locationZ)
	
	if (_use_hitbox_instead_of_dice_colliders):
		_click_hitbox.input_event.connect(_on_die_input_event)
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
		clicked.emit()