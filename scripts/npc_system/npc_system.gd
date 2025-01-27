class_name NPCSystem
extends Node
## Class managing npcs and keeping track of shared data for npcs.
## At this point, this class is not super important, but it would be useful 
## for when npcs need to interact with each other or use the same space.

@export var path_follow_guard_1: PathFollow3D
@export var path_follow_guard_2: PathFollow3D
@export var path_follow_guard_3: PathFollow3D
@export var path_follow_kitchen_1: PathFollow3D
@export var path_follow_kitchen_2: PathFollow3D

var npcs: Array


func _ready():
	npcs = get_node("NPCs").get_children()
	enable_npcs()


func enable_npcs():
	for npc in npcs:
		if npc is AmbientNPCBase:
			npc.on_ready(self)
