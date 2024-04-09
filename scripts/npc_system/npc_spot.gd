class_name NPCSpot
extends Marker3D

var is_claimed := false
var claimer: AmbientNPC
## If NPC need to use the kitchen, they can get a spot in the queue.
var _queue


## TODO: Revisit this later
func try_claim(npc: AmbientNPC, enqueue: bool = true) -> bool:
	if not is_claimed:
		is_claimed = true
		claimer = npc
		return true
		
	return false
	
	#if enqueue:
		#_queue.append(npc)
		
		

func leave():
	is_claimed = false
	claimer = null
	
