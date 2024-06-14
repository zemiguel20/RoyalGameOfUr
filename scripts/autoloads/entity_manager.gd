extends Node
## Used for spawning entities and/or accessing them.


const P1_PIECE_PREFAB: PackedScene = preload("res://scenes/game/entities/piece_white.tscn")
const P2_PIECE_PREFAB: PackedScene = preload("res://scenes/game/entities/piece_black.tscn")
const DIE_PREFAB: PackedScene = preload("res://scenes/game/entities/d4_die.tscn")
const SPOT_PREFAB: PackedScene = preload("res://scenes/game/entities/spot.tscn")


func spawn_board(board_prefab: PackedScene) -> Board:
	# Get spawn point
	var spawn_point = get_tree().get_first_node_in_group("board_spawn")
	if not spawn_point or not spawn_point is Node3D:
		push_warning("No board spawn point found. Using origin.")
		spawn_point = Node3D.new()
	
	var instance = board_prefab.instantiate() as Board
	instance.name = "Board_%d" % instance.get_instance_id()
	add_child(instance)
	instance.global_position = spawn_point.global_position
	instance.global_rotation = spawn_point.global_rotation
	return instance


## Spawns a piece in the given player's start zone of the board.
func spawn_player_piece(player: int, board: Board) -> Piece:
	# Board needs to be ready for the pieces to get placed
	if not board.is_node_ready():
		await board.ready
	
	# Create instance
	var prefab = P1_PIECE_PREFAB if player == General.Player.ONE else P2_PIECE_PREFAB
	var instance = prefab.instantiate() as Piece
	instance.name = "Piece_%d_%d" % [player, instance.get_instance_id()]
	add_child(instance)
	
	# Place piece in start zone
	var start_spot = board.get_free_start_spots(player)[0]
	instance.global_position = start_spot.get_placing_position_global()
	
	# Update game data
	instance.player_owner = player
	instance.current_spot = start_spot
	start_spot.pieces.append(instance)
	
	return instance


## Spawns a die in the given position in the world.
func spawn_die(global_position := Vector3.ZERO) -> Die:
	var instance = DIE_PREFAB.instantiate() as Die
	instance.name = "Die_%d" % instance.get_instance_id()
	add_child(instance)
	instance.global_position = global_position
	return instance


## Creates a stray spot (not connected to the board). Can be used to move pieces
## without affecting the spots of the board.
func spawn_temporary_spot() -> Spot:
	var spot = SPOT_PREFAB.instantiate() as Spot
	spot.name = "TempSpot_%d" % spot.get_instance_id()
	add_child(spot)
	return spot


## Searches for the board in the scene tree.
func get_board() -> Board:
	var filter = func(node: Node): return node is Board and not node.is_queued_for_deletion()
	var boards = get_children().filter(filter)
	if boards.is_empty():
		return null
	else:
		return boards.front() as Board


## Get all spawned dice.
func get_dice() -> Array[Die]:
	var filter = func(node: Node): return node is Die and not node.is_queued_for_deletion()
	var dice: Array[Die] = []
	dice.assign(get_children().filter(filter))
	return dice


## Get all spawned pieces of the given player.
func get_player_pieces(player: int) -> Array[Piece]:
	var filter = func(node: Node): return node is Piece and (node as Piece).player_owner == player \
									and not node.is_queued_for_deletion()
	var pieces = get_children().filter(filter)
	return pieces


func despawn_board() -> void:
	for node in get_children():
		if node is Piece:
			node.current_spot.pieces.erase(node)
			node.queue_free()
	
	var board = get_board()
	if board:
		board.queue_free()


func despawn_dice() -> void:
	for node in get_children():
		if node is Die:
			node.queue_free()
