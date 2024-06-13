## Class managing npcs and keeping track of shared data for npcs.
## At this point, this class is not super important, but it would be useful 
## for when npcs need to interact with each other or use the same space.
class_name NPCSystem
extends Node

var npcs: Array

func _ready():
	## Disable background NPCs when in hotseat mode
	if GameManager.is_hotseat:
		return
	
	npcs = get_node("NPCs").get_children()
	
	for npc in npcs:
		if npc is AmbientNPCBase:
			npc.on_ready(self)
