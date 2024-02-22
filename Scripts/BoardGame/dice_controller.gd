extends Node

@export_category("Dice Info")
@export var scene : PackedScene
@export var numOfDice : int = 4;

@export_category("Audio")
@export var audio_player : AudioStreamPlayer
@export_group("Sound Effects")
@export var SFX_dice_shaking : AudioStream
@export var SFX_dice_roll : AudioStream

@export_category("Extra Features")
@export var enable_roll_shaking : bool
@export var use_hitbox_instead_of_dice_colliders : bool
@export var click_hitbox : CollisionObject3D

var total_roll_value = -1;

var _dice_list : Array
var _num_of_finished_dice = 0

var _is_rolling = false
var _is_shaking_roll = false

## Triggered when
signal roll_started
## Triggered when all dice finished rolling and a final value has been calculated.
signal roll_finished(value : int)

func _ready():
	_initialize_dice()
	if (use_hitbox_instead_of_dice_colliders):
		click_hitbox.input_event.connect(_on_die_input_event)
	
func _input(event):
	if (_is_shaking_roll and 
		event is InputEventMouseButton and 
		event.is_released()):
		_is_shaking_roll = false
		roll_started.emit()
		# TODO: Remove when integrated
		roll()		
		
func roll():
	_start_roll()
	
	_is_rolling = true
	var total_roll_value = await roll_finished
	_is_rolling = false		
		
	return total_roll_value
	
func _initialize_dice():
	for i in range(0, numOfDice):
		var instance = scene.instantiate() as Die
		add_child(instance)
		await Engine.get_main_loop().process_frame
		
		# TODO: Make this editable as well, but this should be handled by a Placer script.
		# This script will then also make sure that the dice do not overlapped.
		var locationX = randf_range(-2.5, 2.5)
		var locationZ = randf_range(-2.5, 2.5)
		instance.global_position = Vector3(locationX, 0, locationZ)
		_dice_list.append(instance)
		
		instance.roll_finished.connect(_on_die_roll_finished)
		if (not use_hitbox_instead_of_dice_colliders):
			instance.input_event.connect(_on_die_input_event)
			
func _start_shake():
	for die in _dice_list:
		die.visible = false
			
		_is_shaking_roll = true
		if (audio_player != null):
			audio_player.stream = SFX_dice_shaking
			audio_player.play()
			
func _start_roll():
	total_roll_value = 0
	_num_of_finished_dice = 0
	
	if (audio_player != null):
		audio_player.stream = SFX_dice_roll
		audio_player.play()
	
	for die : Die in _dice_list:
		die.visible = true
		die.start_rolling()
	
func _on_die_roll_finished(roll_value):
	_num_of_finished_dice += 1
	total_roll_value += roll_value
	
	if (_num_of_finished_dice >= numOfDice):
		roll_finished.emit(total_roll_value)

func _on_die_input_event(_camera, event : InputEvent, _position, _normal, _shape_idx):
	if (_is_rolling):
		return
	
	if event is InputEventMouseButton and event.is_pressed():
		if (not enable_roll_shaking):
			roll_started.emit()
			# TODO: Remove when integrated
			roll()		
		else:
			_start_shake()
