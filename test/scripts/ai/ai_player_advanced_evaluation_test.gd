extends Node
## For this test, we will assume that the AI is Player TWO and the opponent is Player ONE. 

@onready var _ai_player = $AIPlayerAdvanced as AIPlayerAdvanced
@export var _board: Board

func _ready():
	_setup()
	
	# Check all rules individually
	await _test_base_score()
	await _test_safety_modifier()
	await _test_progress_modifier()
	await _test_central_rosette_modifier()
	
	# Test overall AI behaviour
	await _test_best_move()
	print("All tests successfull!")
	
	
func _setup():
	Engine.time_scale = 4.0
	
	
func _reset_pieces_to_start(p1_pieces, p2_pieces):
	var p1_start = _board.get_free_start_spots(General.Player.ONE)
	for i in range(0, p1_pieces.size()):
		await (p1_start[i] as Spot).place_piece(p1_pieces[i], Piece.MoveAnim.ARC)
			
	var p2_start = _board.get_free_start_spots(General.Player.TWO)
	for i in range(0, p2_pieces.size()):
		await (p2_start[i] as Spot).place_piece(p1_pieces[i], Piece.MoveAnim.ARC)


# This function tests the _evaluate_moves and _evaluate_move function
func _test_best_move():
	# Construct 3 moves
	var ai_piece = _board._p2_start_spots[0].pieces.front() as Piece
	var ai_piece2 = _board._p2_start_spots[1].pieces.front() as Piece
	var moves = [] as Array[Move]
	
	# TEST: Check score of rosette move with piece progression
	var mock_current_spot = _board.get_spot(0, General.Player.TWO)
	var mock_landing_spot = _board.get_spot(3, General.Player.TWO) as Spot
	var move1 := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	moves.append(move1)
	
	# Approximately 0.715
	var expected = _ai_player.grants_roll_base_score + 1.0/14.0 * _ai_player.piece_progress_score_weight
	var result = _ai_player._evaluate_move(move1)
	assert(expected == result, "Result %s" % result)
	
	# TEST: Check score of a capture move
	var opponent_piece = _board.get_pieces(General.Player.ONE).front()
	var opponent_landing_spot = _board.get_spot(4, General.Player.ONE) 
	await _board.move(opponent_piece, opponent_landing_spot)

	var starting_spot = _board.get_current_spot(ai_piece2)
	mock_landing_spot = _board.get_spot(4, General.Player.TWO)
	var move2 := Move.new(ai_piece2, starting_spot, mock_landing_spot)
	moves.append(move2)
	
	expected = _ai_player.capture_base_score
	result = _ai_player._evaluate_move(move2)
	assert(expected == result, "Result %s" % result)
	
	# TEST: Capture move should be the best move.
	# NOTE: This final test depends on the values.
	expected = move2
	result = _ai_player._evaluate_moves(moves) as Move
	assert(expected == result, "Result %s" % result)
	
	await _reset_pieces_to_start([opponent_piece], [ai_piece, ai_piece2])
	

#region Base score tests
func _test_base_score():
	# TEST: Normal base score, by moving to an empty normal square
	# Setup AI Move to normal space and capture space
	var ai_piece = _board._p2_start_spots[0].pieces.front()
	var mock_current_spot = _board.get_spot(2, _ai_player._player_id)
	var mock_landing_spot = _board.get_spot(4, _ai_player._player_id) as Spot
	var normal_move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	var expected = _ai_player.regular_base_score
	var result = _ai_player._calculate_base_score(normal_move)
	assert(expected == result, "Base score result: %d" % result)
	
	# TEST: Capture base score, by moving a player piece.
	var opponent_landing_spot = _board.get_spot(4, General.Player.ONE)
	var opponent_piece = _board.get_pieces(General.Player.ONE)[0]
	await _board.move(opponent_piece, opponent_landing_spot)
	
	expected = _ai_player.capture_base_score
	result = _ai_player._calculate_base_score(normal_move)
	assert(expected == result, "Base score result: %d" % result)
	
	# TEST: Grants extra roll base score. In this test, rosette will grant extra rolls.
	mock_landing_spot = _board.get_spot(7, General.Player.TWO) as Spot
	var rosette_move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	expected = _ai_player.grants_roll_base_score
	result = _ai_player._calculate_base_score(rosette_move)
	assert(expected == result, "Base score result: %d" % result)
	
	# TEST: Move to end base score
	mock_landing_spot = _board._p2_end_area.get_available_spot()
	var end_move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	expected = _ai_player.end_move_base_score
	result = _ai_player._calculate_base_score(end_move)
	assert(expected == result, "Base score result: %d" % result)
	
	print("Base score tests completed!")	
	
#endregion
	
#region Safety Modifier Tests
# Tests for the safety modifier when starting the move in a safe spot.
func _test_safety_modifier():
	await _test_safety_modifier_to_danger()
	await _test_safety_modifier_to_safety()


func _test_safety_modifier_to_danger():
	# Setup for test: AI will move to the first unsafe tile
	var ai_piece = _board.get_pieces(General.Player.TWO).front()
	var mock_current_spot = _board.get_spot(2, General.Player.TWO)
	var mock_landing_spot = _board.get_spot(4, General.Player.TWO) as Spot
	var move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	# Set safety_score_weight to 1 to better test the outcome.
	_ai_player.safety_score_weight = 1.0	
	
	# TEST: When no opponent pieces are in range, shared spots have a base base_danger_score
	var expected = -_ai_player.base_spot_danger
	var result = _ai_player._calculate_safety_modifier(move)	
	assert(expected == result, "Result: %d" % result)
	
	# TEST: 
	# Move opponent piece
	var landing_spot1 = _board.get_spot(0, General.Player.ONE)
	var piece1 = _board.get_pieces(General.Player.ONE)[0]
	await _board.move(piece1, landing_spot1)
	
	# Opponent needs to throw 4 in order to capture, so 1/16 chance.
	expected = -(_ai_player.base_spot_danger + 1.0/16.0)
	result = _ai_player._calculate_safety_modifier(move)	
	assert(expected == result, "Result: %d" % result)

	# TEST: When there are 4(MAX) opponent pieces in range
	for i in range(1,4):
		var landing_spot = _board.get_spot(i, General.Player.ONE)
		var piece = _board.get_pieces(General.Player.ONE)[i]
		await _board.move(piece, landing_spot)
	
	# Opponent needs to not throw 0 in order to capture, so 15/16 chance.	
	expected = -(_ai_player.base_spot_danger + 15.0/16.0)
	result = _ai_player._calculate_safety_modifier(move)
	assert(expected == result, "Result: %d" % result)
	print("Danger safety tests completed!")
	
	
func _test_safety_modifier_to_safety():
	# Setup for test: AI will move from unsafe tile to a safe rosette
	var ai_piece = _board.get_pieces(General.Player.TWO).front()
	var mock_current_spot = _board.get_spot(4, General.Player.TWO)
	var mock_landing_spot = _board.get_spot(7, General.Player.TWO) as Spot
	var move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	# Set safety_score_weight to 1 to better test the outcome.
	_ai_player.safety_score_weight = 1.0	
	
	# TEST: Move from dangerous spot to a safe spot
	var expected = _ai_player.base_spot_danger + 15.0/16.0
	var result = _ai_player._calculate_safety_modifier(move)
	assert(expected == result, "Result: %d" % result)
	
	# TEST: Test moving to a place that is still dangerous, but less dangerous
	var mock_landing_spot2 = _board.get_spot(5, General.Player.TWO) as Spot
	var move2 = Move.new(ai_piece, mock_current_spot, mock_landing_spot2)
	
	# Danger on new spot is 11/16 + base_danger_score, since opponent can throw 2, 3 or 4
	# I put the whole calculation here due to float precision
	expected = (_ai_player.base_spot_danger + 15.0/16.0 - _ai_player.base_spot_danger - 11.0/16.0)
	result = _ai_player._calculate_safety_modifier(move2)	
	assert(expected == result, "Result: %d" % result)
	
	# TEST: Test going from a shared but safe spot to a 100% safe spot
	await _reset_pieces_to_start([], [ai_piece])
	
	expected = _ai_player.base_spot_danger
	result = _ai_player._calculate_safety_modifier(move)	
	assert(expected == result, "Result: %d" % result)
#endregion	
	
#region Progress Score Modifier Tests
func _test_progress_modifier():
	# Get a piece that is in the starting area
	var ai_piece = _board.get_pieces(General.Player.TWO).front()
	
	# TEST: Progress modifier of spot in starting zone
	var mock_current_spot = _board.get_current_spot(ai_piece)
	var mock_landing_spot = _board.get_spot(1, General.Player.TWO) as Spot
	var move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	var expected = 0.0 * _ai_player.piece_progress_score_weight
	var result = _ai_player._calculate_progress_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	# TEST: Progress modifier of first tile should be higher than the starting zone!
	mock_current_spot = _board.get_spot(0, General.Player.TWO)
	mock_landing_spot = _board.get_spot(2, General.Player.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)	
	
	expected = 1.0/_board.get_track_size(General.Player.TWO) * _ai_player.piece_progress_score_weight
	result = _ai_player._calculate_progress_modifier(move)
	assert(expected == result, "Result %s" % result)	
	
	# TEST: Progress modifier of spot on player exclusive part
	mock_current_spot = _board.get_spot(2, General.Player.TWO)
	mock_landing_spot = _board.get_spot(4, General.Player.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)		
	
	expected = 3.0/_board.get_track_size(General.Player.TWO) * _ai_player.piece_progress_score_weight
	result = _ai_player._calculate_progress_modifier(move)
	assert(expected == result, "Result %s" % result)	
	
	# TEST: Progress modifier of spot in shared path 
	mock_current_spot = _board.get_spot(9, General.Player.TWO)
	mock_landing_spot = _board.get_spot(11, General.Player.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)		
	
	expected = 10.0/_board.get_track_size(General.Player.TWO) * _ai_player.piece_progress_score_weight
	result = _ai_player._calculate_progress_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	print("Progress Modifier Tests Completed!")
#endregion	
	
#region Central Rosette Tests
func _test_central_rosette_modifier():
	# TEST: Move to a regular spot, no score
	var ai_piece = _board.get_pieces(General.Player.TWO).front()
	
	var mock_current_spot = _board.get_spot(0, General.Player.TWO) as Spot
	var mock_landing_spot = _board.get_spot(2, General.Player.TWO) as Spot
	var move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	var expected = 0.0 * _ai_player.central_rosette_score_weight
	var result = _ai_player._calculate_central_rosette_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	# TEST: Move to a player exclusive rosette
	mock_current_spot = _board.get_spot(0, General.Player.TWO) as Spot
	mock_landing_spot = _board.get_spot(3, General.Player.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	expected = 0.0 * _ai_player.central_rosette_score_weight
	result = _ai_player._calculate_central_rosette_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	# TEST: Move towards a central rosette with many pieces still at the start.
	mock_current_spot = _board.get_spot(1, General.Player.TWO) as Spot
	mock_landing_spot = _board.get_spot(7, General.Player.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	expected = 1.0 * _ai_player.central_rosette_score_weight
	result = _ai_player._calculate_central_rosette_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	# TEST: Negative score when moving away from central rosette. 
	mock_current_spot = _board.get_spot(7, General.Player.TWO) as Spot
	mock_landing_spot = _board.get_spot(10, General.Player.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	expected = -1.0 * _ai_player.central_rosette_score_weight
	result = _ai_player._calculate_central_rosette_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	# TEST: Move towards a central rosette when half of the players pieces have passed this spot.
	# TODO: Change this test according to the changes in this rule
	# Move 3 opponent pieces past the rosette
	for _i in range(0, 3):
		var piece: Piece = _board.get_pieces(General.Player.ONE)[_i]
		var landing_spot = _board.get_spot(8 + _i, General.Player.ONE)
		await _board.move(piece, landing_spot)
		
	# Move 2 opponent piece to the end zone
	for _i in range(3, 5):
		var piece: Piece = _board.get_pieces(General.Player.ONE)[_i]
		var landing_spot = _board._p1_end_area.get_available_spot()
		await _board.move(piece, landing_spot)
		
	mock_current_spot = _board.get_spot(1, General.Player.TWO) as Spot
	mock_landing_spot = _board.get_spot(7, General.Player.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	expected = (1.0 - 5.0/7.0) * _ai_player.central_rosette_score_weight
	result = _ai_player._calculate_central_rosette_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	# TEST: Test turning the decreasing score rule off.
	_ai_player.decrease_per_passed_opponent_piece = false
	
	expected = 1.0 * _ai_player.central_rosette_score_weight
	result = _ai_player._calculate_central_rosette_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	print("Central Rosette Modifiers Tests Completed!")
#endregion	
