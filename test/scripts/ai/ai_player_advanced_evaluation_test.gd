extends Node


@onready var ai_player = $AIPlayerAdvanced


func _ready():
	test_move_1()
	test_one_move()
	
	
func test_move_1():
	var moves : Array[Move]
	
	var piece1 = Piece.new()
	var piece2 = Piece.new()
	var piece3 = Piece.new()
	
	var move1 = Move.new(piece1, null, true)
	moves.append(move1)
	
	var move2 = Move.new(piece2, null, false)
	moves.append(move2)
	
	var move3 = Move.new(piece3, null, true)
	moves.append(move3)
	
	var expected = move1.piece
	var result = ai_player._evaluate_moves(moves)
	
	assert(expected == result)

	
func test_one_move():
	var moves : Array[Move]
	
	var piece1 = Piece.new()	
	var move1 = Move.new(piece1, null, true)
	moves.append(move1)
	
	var expected = move1.piece
	var result = ai_player._evaluate_moves(moves)
	
	assert(expected == result)
