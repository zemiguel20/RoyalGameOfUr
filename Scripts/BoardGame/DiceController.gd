extends Node

@export var numOfDice = 4;
@export var scene : PackedScene

var random
var dice_list : Array

func _ready():
	random = RandomNumberGenerator.new()
	for i in range(0, numOfDice):
		var instance = scene.instantiate() as Area3D
		
		#TODO: Make this editable as well, but this should be handled by a Placer script.
		# This script will then also make sure that the dice do not overlapped.
		var locationX = random.randf_range(-2.5, 2.5)
		var locationZ = random.randf_range(-2.5, 2.5)
		instance.position = Vector3(locationX, 0, locationZ)
		instance.input_event.connect(_on_die_input_event)
		dice_list.append(instance)
		add_child(instance)
		
	print(dice_list.size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func roll():
	var totalRoll = 0;
	
	for i in range(0, numOfDice):
		totalRoll += random.randi_range(0, 1);
	
	return totalRoll

func _on_die_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		print(roll())
