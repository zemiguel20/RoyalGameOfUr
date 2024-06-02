class_name EntityManager extends Node


@export var p1_piece_prefab: PackedScene
@export var p2_piece_prefab: PackedScene
@export var die_prefab: PackedScene

@export var board: Board
@export var dice_spawn_spot: Node3D

var p1_pieces: Array[Piece] = []
var p2_pieces: Array[Piece] = []

var dice: Array[Die] = []


func spawn_player_pieces(num_pieces: int) -> void:
	# Board needs to be ready for the pieces to get placed
	if not board.is_node_ready():
		await board.ready
	
	for i in num_pieces:
		_spawn_piece(General.Player.ONE, p1_piece_prefab, p1_pieces)
		_spawn_piece(General.Player.TWO, p2_piece_prefab, p2_pieces)


func spawn_dice(num_die: int) -> void:
	for i in num_die:
		var instance = die_prefab.instantiate() as Die
		add_child(instance)
		dice.append(instance)
		instance.global_position = dice_spawn_spot.global_position


func spawn_temporary_spot() -> Spot:
	var spot = Spot.new()
	add_child(spot)
	return spot


func _spawn_piece(player: int, prefab: PackedScene, pieces_array: Array[Piece]):
	var instance = prefab.instantiate() as Piece
	add_child(instance)
	pieces_array.append(instance)
	
	instance.player_owner = player
	
	# Place piece in start zone
	var start_spot = board.get_free_start_spots(player).front() as Spot
	instance.current_spot = start_spot
	instance.global_position = start_spot.get_placing_position_global()
	start_spot.pieces.append(instance)
