extends Node
## Self destroys on start. Useful to clear helper nodes for the editor that have no use in game.


func _ready() -> void:
	queue_free()
