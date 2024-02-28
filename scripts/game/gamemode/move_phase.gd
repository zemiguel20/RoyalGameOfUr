class_name MovePhase
extends Phase
## Rolling phase of the [Gamemode]. Implements behaviour for the piece move action.



var _legal_pieces: Array[Piece]
var _legal_moves: Array[Move]


## Checks the possible moves for the current player and highlights those pieces.
## If there are no possible moves, then changes directly to the next player's [RollPhase]
func start():
	_calculate_legal_moves()
	
	if _legal_moves.is_empty():
		_gamemode.switch_player()
		_gamemode.changeState(RollPhase.new(_gamemode))
		return
	
	_link_highlighting()
	_enable_piece_selection()
		
	if (_gamemode.is_ai_turn()):
		_gamemode.ai_player.make_move(_legal_moves)
	else:
		for piece in _legal_pieces:
			piece.enable_selection()

## Disables highlighting of the movable pieces calculated in [method start] 
func end():
	_unlink_highlighting()


## Moves the [param piece]. If player gets an extra roll, then move to the [RollPhase] again. If player wins, then end the game.
## Otherwise, changes to the next player's [RollPhase].
func move(piece: Piece):
	_disable_piece_selection()
	
	var landing_spot = _gamemode.board.get_landing_spot(piece, _gamemode.dice.value)
	if landing_spot != null:
		await _gamemode.board.move(piece, landing_spot)
	
	if _gamemode.board.is_winner(_gamemode.current_player):
		_gamemode.end_game()
		return
	
	if landing_spot.give_extra_roll:
		_gamemode.got_extra_roll.emit()
	else:
		_gamemode.switch_player()
	
	_gamemode.changeState(RollPhase.new(_gamemode))


func _calculate_legal_moves():
	_legal_moves = {}
	var pieces = _gamemode.board.get_pieces(_gamemode.current_player)
	for piece in pieces:
		var landing_spot = _gamemode.board.get_landing_spot(piece, _gamemode.dice.value)
		if landing_spot != null and (not _has_player_piece(landing_spot) or not _is_protecting_opponent(landing_spot)):
			_legal_pieces.append(piece)
			var legal_move = Move.new(piece, landing_spot, landing_spot.is_rosette, _is_capturable(landing_spot))
			_legal_moves.append(legal_move)


func _has_player_piece(spot: Spot) -> bool:
	return  _gamemode.board.is_occupied_by_player(spot, _gamemode.current_player)


func _is_protecting_opponent(spot: Spot) -> bool:
	var other_player_id = General.get_other_player_id(_gamemode.current_player)
	return _gamemode.board.is_occupied_by_player(spot, other_player_id) and spot.is_safe


func _enable_piece_selection() -> void:
	for piece in _legal_moves:
		piece.enable_selection()


func _disable_piece_selection() -> void:
	for piece: Piece in _legal_moves:
		piece.disable_selection()


func _link_highlighting() -> void:
	for piece in _legal_moves:
		var spot = _legal_moves[piece] as Spot
		piece.mouse_entered.connect(spot.highlight)
		piece.mouse_exited.connect(spot.dehighlight)


func _unlink_highlighting() -> void:
	for piece in _legal_moves:
		var spot = _legal_moves[piece] as Spot
		piece.mouse_entered.disconnect(spot.highlight)
		piece.mouse_exited.disconnect(spot.dehighlight)
		
## Used by AI, will refactor later. It makes more sense to have an "is_occupied" in general as well.
func _is_capturable(spot: Spot) -> bool:
	var other_player_id = General.get_other_player_id(_gamemode.current_player)
	return _gamemode.board.is_occupied_by_player(spot, other_player_id) and not spot.is_rosette
	
