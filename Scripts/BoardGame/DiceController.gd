extends Node

@export var numOfDice = 4;
@export var scene : PackedScene

var random
var dice_list : Array

var num_of_finished_dice = 0
var total_roll_value = -1;

signal roll_finished(value : int)

func _ready():
	initialize_dice()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
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
	
	# Do this through the rolling state
	for die : Die in dice_list:
		die.start_rolling()
		
	var total_roll_value = await roll_finished
		
	print("Result: %s" % total_roll_value)
	return total_roll_value

func _on_die_roll_finished(roll_value):
	num_of_finished_dice += 1
	total_roll_value += roll_value
	
	if (num_of_finished_dice >= numOfDice):
		emit_signal("roll_finished", total_roll_value)

func _on_die_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		start_roll()
