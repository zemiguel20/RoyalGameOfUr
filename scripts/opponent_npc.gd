class_name OpponentNPC
extends MeshInstance3D
## NOTE: Rather than inheriting MeshInstance we should have one.

@onready var dialogue_system = $DialogueSystem as DialogueSystem

func _ready():
	material_override = get_active_material(0).duplicate()	
	_debug_set_color(Color.GRAY)		
	
	await get_tree().create_timer(2.0).timeout
	start_dialogue_sequence()
	

func start_dialogue_sequence():
	while dialogue_system.has_next():
		_debug_set_color(Color.SEA_GREEN)
		await dialogue_system.play_next()
		_debug_set_color(Color.GRAY)		
		await get_tree().create_timer(randf_range(5.0, 10.0)).timeout


func _play_interruption():
	await dialogue_system.interrupt()
	

func _on_gamemode_rolled_zero():
	_play_interruption()


func _debug_set_color(color: Color):
	(material_override as BaseMaterial3D).albedo_color = color

