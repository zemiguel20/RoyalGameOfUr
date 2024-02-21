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

var dice_list : Array

var num_of_finished_dice = 0
var total_roll_value = -1;

var temp_is_rolling = false
var is_shaking_roll = false


signal roll_finished(value : int)
## Signal used by DiceResultLabel, this will be replaced by a direct call on the DiceResultLabel script 
## when the rolling phase is entered
signal roll_started

func _ready():
	initialize_dice()
	
func initialize_dice():
	for i in range(0, numOfDice):
		var instance = scene.instantiate() as Die
		add_child(instance)
		await Engine.get_main_loop().process_frame
		
		# TODO: Make this editable as well, but this should be handled by a Placer script.
		# This script will then also make sure that the dice do not overlapped.
		var locationX = randf_range(-2.5, 2.5)
		var locationZ = randf_range(-2.5, 2.5)
		instance.global_position = Vector3(locationX, 0, locationZ)
		dice_list.append(instance)
		instance.input_event.connect(_on_die_input_event)
		instance.roll_finished.connect(_on_die_roll_finished)

func start_roll():
	total_roll_value = 0
	num_of_finished_dice = 0
	
	if (audio_player != null):
		audio_player.stream = SFX_dice_roll
		audio_player.play()
	
	# Do this through the rolling state
	for die : Die in dice_list:
		die.visible = true
		die.start_rolling()
	
	emit_signal("roll_started")
	temp_is_rolling = true
	var total_roll_value = await roll_finished
	temp_is_rolling = false		
		
	print("Result: %s" % total_roll_value)
	return total_roll_value

func _on_die_roll_finished(roll_value):
	num_of_finished_dice += 1
	total_roll_value += roll_value
	
	if (num_of_finished_dice >= numOfDice):
		emit_signal("roll_finished", total_roll_value)

func _on_die_input_event(camera, event : InputEvent, position, normal, shape_idx):
	if (temp_is_rolling):
		return
	
	if event is InputEventMouseButton and event.is_pressed():
		if (not enable_roll_shaking):
			start_roll()
		else:
			for die in dice_list:
				die.visible = false
			
			is_shaking_roll = true
			if (audio_player != null):
				audio_player.stream = SFX_dice_shaking
				audio_player.play()
			
func _input(event):
	if (is_shaking_roll and 
		event is InputEventMouseButton and 
		event.is_released()):
		start_roll()
		is_shaking_roll = false
