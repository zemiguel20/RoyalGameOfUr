class_name NPCDataManager
extends Node
## Experimental name, keeps track of places that are occupied, maybe also has a queue/reserving system.

# Expansion: Dictionary with location type and bool if occupied?
@export var kitchen: NPCSpot
var npcs: Array

func _ready():
	npcs = get_child(0).get_children()
	
	for npc in npcs:
		npc.on_ready(self)