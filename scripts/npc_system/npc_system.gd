class_name NPCSystem
extends Node
## Class managing npcs and keeping track of shared data for npcs.
## At this point, this class is not super important, but it would be useful 
## for when npcs need to interact with each other or use the same space.

@export var dialogue_system: DialogueSystem
var npcs: Array


func _ready():
	npcs = get_node("NPCs").get_children()
	GameEvents.play_pressed.connect(_on_play_pressed)
	

func _on_play_pressed():
	for npc in npcs:
		if npc is AmbientNPCBase:
			npc.on_ready(self)
