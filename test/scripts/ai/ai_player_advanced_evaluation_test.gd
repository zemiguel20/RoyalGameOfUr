extends Node

@onready var board = $Board as Board
@onready var ai_player = $AIPlayerAdvanced as AIPlayerAdvanced
@onready var gamemode = $Gamemode as Gamemode


func _ready():
	_setup()
	await _test_base_score()
	await _reset_pieces_to_start()
	await _test_safety_modifier()
	await _reset_pieces_to_start()
	await _test_progress_modifier()
	print("All tests successfull!")
	
	
func _setup():
	# Manual setup for ai_player lol
	Engine.time_scale = 4.0
	board.setup(7)
	ai_player.setup(gamemode, General.PlayerID.TWO)
	
	
func _reset_pieces_to_start():
	# Move player_one pieces to starts
	for piece: Piece in board.get_pieces(General.PlayerID.ONE):
		if (not board.is_in_start_zone(piece)):
			var spot = board._p1_start_area.get_available_spot()
			await board.move(piece, spot)
			
	for piece: Piece in board.get_pieces(General.PlayerID.TWO):
		if (not board.is_in_start_zone(piece)):
			var spot = board._p2_start_area.get_available_spot()
			await board.move(piece, spot)


#region Base score tests
func _test_base_score():
	# TEST: Normal base score, by moving to an empty normal square
	# Setup AI Move to normal space and capture space
	var ai_piece = board.get_pieces(General.PlayerID.TWO).front()
	var mock_current_spot = board.get_spot(2, General.PlayerID.TWO)
	var mock_landing_spot = board.get_spot(4, General.PlayerID.TWO) as Spot
	var normal_move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	var expected1 = ai_player.regular_base_score
	var result1 = ai_player._calculate_base_score(normal_move)
	assert(expected1 == result1, "Base score result: %d" % result1)
	
	# TEST: Capture base score, by moving a player piece.
	var landing_spot1 = board.get_spot(4, General.PlayerID.ONE)
	var piece1 = board.get_pieces(General.PlayerID.ONE)[0]
	await board.move(piece1, landing_spot1)
	
	var expected2 = ai_player.capture_base_score
	var result2 = ai_player._calculate_base_score(normal_move)
	assert(expected2 == result2, "Base score result: %d" % result2)
	
	# TEST: Grants extra roll base score. In this test, rosette will grant extra rolls.
	var mock_landing_spot2 = board.get_spot(7, General.PlayerID.TWO) as Spot
	var rosette_move := Move.new(ai_piece, mock_current_spot, mock_landing_spot2)
	
	var expected3 = ai_player.grants_roll_base_score
	print("Extra Roll: ", mock_landing_spot2.give_extra_roll)
	print("Safe: ", mock_landing_spot2.is_safe)
	var result3 = ai_player._calculate_base_score(rosette_move)
	assert(expected3 == result3, "Base score result: %d" % result3)
	
	# TEST: Move to end base score
	var mock_landing_spot3 = board._p2_end_area.get_available_spot()
	var end_move := Move.new(ai_piece, mock_current_spot, mock_landing_spot3)
	
	var expected4 = ai_player.end_move_base_score
	var result4 = ai_player._calculate_base_score(end_move)
	assert(expected4 == result4, "Base score result: %d" % result4)
	print("Base score tests successfull!")	
	
#endregion
	
#region Safety Modifier Tests
# Tests for the safety modifier when starting the move in a safe spot.
func _test_safety_modifier():
	await _test_safety_modifier_to_danger()
	await _test_safety_modifier_to_safety()


func _test_safety_modifier_to_danger():
	# Setup for test: AI will move to the first unsafe tile
	var ai_piece = board.get_pieces(General.PlayerID.TWO).front()
	var mock_current_spot = board.get_spot(2, General.PlayerID.TWO)
	var mock_landing_spot = board.get_spot(4, General.PlayerID.TWO) as Spot
	var move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	# Set safety_score_weight to 1 to better test the outcome.
	ai_player.safety_score_weight = 1.0	
	
	# TEST: When no opponent pieces are in range, shared spots have a base base_danger_score
	var expected1 = -ai_player.base_spot_danger
	var result1 = ai_player._calculate_safety_modifier(move)	
	assert(expected1 == result1, "Result: %d" % result1)
	
	# TEST: 
	var landing_spot1 = board.get_spot(0, General.PlayerID.ONE)
	var piece1 = board.get_pieces(General.PlayerID.ONE)[0]
	await board.move(piece1, landing_spot1)
	
	# Opponent needs to throw 4 in order to capture, so 1/16 chance.
	var expected2 = -(ai_player.base_spot_danger + 1.0/16.0)
	var result2 = ai_player._calculate_safety_modifier(move)	
	assert(expected2 == result2, "Result: %d" % result2)

	# TEST: When there are 4(MAX) opponent pieces in range
	for i in range(1,4):
		var landing_spot = board.get_spot(i, General.PlayerID.ONE)
		var piece = board.get_pieces(General.PlayerID.ONE)[i]
		await board.move(piece, landing_spot)
	
	# Opponent needs to not throw 0 in order to capture, so 15/16 chance.	
	var expected3 = -(ai_player.base_spot_danger + 15.0/16.0)
	var result3 = ai_player._calculate_safety_modifier(move)
	assert(expected3 == result3, "Result: %d" % result3)
	print("Danger safety tests completed")
	
	
func _test_safety_modifier_to_safety():
	# Setup for test: AI will move from unsafe tile to a safe rosette
	var ai_piece = board.get_pieces(General.PlayerID.TWO).front()
	var mock_current_spot = board.get_spot(4, General.PlayerID.TWO)
	var mock_landing_spot = board.get_spot(7, General.PlayerID.TWO) as Spot
	var move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	# Set safety_score_weight to 1 to better test the outcome.
	ai_player.safety_score_weight = 1.0	
	
	# TEST: Move from dangerous spot to a safe spot
	var expected1 = ai_player.base_spot_danger + 15.0/16.0
	var result1 = ai_player._calculate_safety_modifier(move)
	assert(expected1 == result1, "Result: %d" % result1)
	
	# TEST: Test moving to a place that is still dangerous, but less dangerous
	var mock_landing_spot2 = board.get_spot(5, General.PlayerID.TWO) as Spot
	var move2 := Move.new(ai_piece, mock_current_spot, mock_landing_spot2)
	
	# Danger on new spot is 11/16 + base_danger_score, since opponent can throw 2, 3 or 4
	# I put the whole calculation here due to float precision
	var expected2 = (0.1 + 15.0/16.0 - 0.1 - 11.0/16.0)
	var result2 = ai_player._calculate_safety_modifier(move2)	
	assert(expected2 == result2, "Result: %d" % result2)
	
	# TEST: Test going from a shared but safe spot to a 100% safe spot
	await _reset_pieces_to_start()
	
	var expected3 = ai_player.base_spot_danger
	var result3 = ai_player._calculate_safety_modifier(move)	
	assert(expected3 == result3, "Result: %d" % result3)
#endregion	
	
#region Progress Score Modifier Tests
func _test_progress_modifier():
	# Get a piece that is in the starting area
	var ai_piece = board.get_pieces(General.PlayerID.TWO).front()
	
	# TEST: Progress modifier of spot in starting zone
	var mock_current_spot = board.get_current_spot(ai_piece)
	var mock_landing_spot = board.get_spot(1, General.PlayerID.TWO) as Spot
	var move := Move.new(ai_piece, mock_current_spot, mock_landing_spot)
	
	var expected = 0.0 * ai_player.piece_progress_score_weight
	var result = ai_player._calculate_progress_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	# TEST: Progress modifier of first tile should be higher than the starting zone!
	mock_current_spot = board.get_spot(0, General.PlayerID.TWO)
	mock_landing_spot = board.get_spot(2, General.PlayerID.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)	
	
	expected = 1.0/board.get_track_size(General.PlayerID.TWO) * ai_player.piece_progress_score_weight
	result = ai_player._calculate_progress_modifier(move)
	assert(expected == result, "Result %s" % result)	
	
	# TEST: Progress modifier of spot on player exclusive part
	mock_current_spot = board.get_spot(2, General.PlayerID.TWO)
	mock_landing_spot = board.get_spot(4, General.PlayerID.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)		
	
	expected = 3.0/board.get_track_size(General.PlayerID.TWO) * ai_player.piece_progress_score_weight
	result = ai_player._calculate_progress_modifier(move)
	assert(expected == result, "Result %s" % result)	
	
	# TEST: Progress modifier of spot in shared path 
	mock_current_spot = board.get_spot(9, General.PlayerID.TWO)
	mock_landing_spot = board.get_spot(11, General.PlayerID.TWO) as Spot
	move = Move.new(ai_piece, mock_current_spot, mock_landing_spot)		
	
	expected = 10.0/board.get_track_size(General.PlayerID.TWO) * ai_player.piece_progress_score_weight
	result = ai_player._calculate_progress_modifier(move)
	assert(expected == result, "Result %s" % result)
	
	print("Progress Modifier Tests Complete!")
#endregion	
	
#region Central Rosette Tests

#endregion	
	
#region To Move! Random AI
## From here we test the random ai	
	
#func test_move_1():
	#var moves : Array[Move]
	#
	#
	#var move1 = Move.new(piece1, null, true)
	#moves.append(move1)
	#
	#var move2 = Move.new(piece2, null, false)
	#moves.append(move2)
	#
	#var move3 = Move.new(piece3, null, true)
	#moves.append(move3)
	#
	#var expected = move1.piece
	#var result = ai_player._evaluate_moves(moves)
	#
	#assert(expected == result)
#
	#
#func test_one_move():
	#var moves : Array[Move]
	#
	#var piece1 = Piece.new()	
	#var move1 = Move.new(piece1, null, true)
	#moves.append(move1)
	#
	#var expected = move1.piece
	#var result = ai_player._evaluate_moves(moves)
	#
	#assert(expected == result)
	
#endregion
