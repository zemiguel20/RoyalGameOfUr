extends Node

@export var numOfDice = 4;
@export var scene : PackedScene
@onready var scene2 = preload("res://Die.tscn") 

var random

func _ready():
	random = RandomNumberGenerator.new()
	for i in range(0, numOfDice):
		var instance = scene.instantiate() as Area3D
		var location = random.randf_range(-2, 2)
		instance.position = Vector3(location, 0, location)
		instance.input_event.connect(_on_die_input_event)
		add_child(instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func roll():
	var totalRoll = 0;
	
	for i in range(0, numOfDice):
		totalRoll += random.randi_range(0, 1);
	
	return totalRoll

func _on_die_input_event(camera, event, position, normal, shape_idx):
	print(roll())
