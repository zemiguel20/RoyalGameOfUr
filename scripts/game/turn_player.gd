class_name PlayerTurn
extends Turn


func start() -> void:
	await _scene_tree.create_timer(1.0).timeout
	var rand_result = Result[Result.keys()[randi() % Result.size()]]
	finished.emit(rand_result)
