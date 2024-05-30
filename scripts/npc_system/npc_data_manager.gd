## Class managing npcs and keeping track of shared data for npc, making sure that they do not overlap.
class_name NPCSystem
extends Node

var npcs: Array

func _ready():
	npcs = get_node("NPCs").get_children()
	
	for npc in npcs:
		if npc is AmbientNPCBase:
			npc.on_ready(self)
