class_name OpponentNPC
extends Node3D

@export var talking_animation: Animation

## Amount of seconds after starting the game before the npc begins the starting dialogue. 
@export_group("Dialogue Settings")
@export var starting_dialogue_delay: float = 2.0
@export var min_time_between_dialogues: float = 5.0
@export var max_time_between_dialogues: float = 10.0
## When a reaction plays, we delay the next dialogue, 
## to prevent the dialogue interrupting the reaction or the dialogue being skipped.
@export var reaction_dialogue_delay: float = 5.0

@onready var dialogue_system = $DialogueSystem as DialogueSystem
@onready var mesh = $MeshInstance3D as MeshInstance3D

var _time_until_next_dialogue: float
var _is_interrupting: bool
## Reconsider timer vs awaiting
## Pros: More control over the time
var _is_timer_active: bool

func _ready():
	# Some debug material logic
	mesh.material_override = mesh.get_active_material(0).duplicate()	
	_debug_set_color(Color.GRAY)		
	
	# Start first dialogue after a delay.
	await get_tree().create_timer(starting_dialogue_delay).timeout
	start_next_dialogue()
	_is_timer_active = true	
	
#
#func start_dialogue_sequence():
	#while dialogue_system.has_next():
		#_debug_set_color(Color.SEA_GREEN)
		#await dialogue_system.play_next()
		#_debug_set_color(Color.GRAY)		
		#_time_until_next_dialogue = randf_range(5.0, 10.0)
		##await get_tree().create_timer(randf_range(5.0, 10.0)).timeout

func _process(delta):
	if not _is_timer_active or dialogue_system.is_busy():
		return 
		
	_time_until_next_dialogue -= delta
	print("Time: ", _time_until_next_dialogue)
	
	if _time_until_next_dialogue <= 0:
		start_next_dialogue()
		
		
func start_next_dialogue():
	_debug_set_color(Color.SEA_GREEN)
	await dialogue_system.play_next()
	_debug_set_color(Color.GRAY)		
	if dialogue_system.has_next():
		_time_until_next_dialogue = randf_range(min_time_between_dialogues, max_time_between_dialogues)
	else:
		_is_timer_active = false


## Could also name this play_reaction
func _play_interruption():
	_debug_set_color(Color.SEA_GREEN)
	_is_interrupting = true
	_time_until_next_dialogue += reaction_dialogue_delay
	await dialogue_system.interrupt()
	_is_interrupting = false
	

func _on_gamemode_rolled_zero():
	_play_interruption()


func _debug_set_color(color: Color):
	(mesh.material_override as BaseMaterial3D).albedo_color = color

