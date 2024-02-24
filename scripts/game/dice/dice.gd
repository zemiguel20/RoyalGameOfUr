class_name Dice
extends Node
## Dice controller. Controls the dice rolling animation and stores its value.


signal clicked

@export_range(0, 8) var _num_of_dice: int = 4
@export var _roll_shaking_enabled: bool = false
@export var _use_hitbox_instead_of_dice_colliders : bool

var value: int = 0 ## Current rolled value.

var _die_scene: PackedScene = preload("res://scenes/gameplay/dice/d4.tscn")
var _dice : Array[Die]
var _is_shaking: bool = false
var _die_finish_count = 0
@onready var _roll_sfx: AudioStreamPlayer = $RollSFX
@onready var _shake_sfx: AudioStreamPlayer = $ShakeSFX
@onready var _click_hitbox : Area3D = $ClickHitbox


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
	value = 0
	_die_finish_count = 0
	for die in _dice:
		die.roll()
	while _die_finish_count < _num_of_dice:
		await get_tree().create_timer(0.5).timeout
	enable_selection()
	return value


func _initialize_dice() -> void:
	for _i in _num_of_dice:
		var instance = _die_scene.instantiate() as Die
		add_child(instance)
		_dice.append(instance)
		instance.roll_finished.connect(_on_die_finished_rolling)
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
		for die in _dice:
				die.visible = true
		clicked.emit()


func _on_die_finished_rolling(die_value: int):
	value += die_value
	_die_finish_count += 1
