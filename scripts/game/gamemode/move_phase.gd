class_name MovePhase
extends Phase
## Rolling phase of the [Gamemode]. Implements behaviour for the piece move action.


var _legal_moves: Array[Piece]


## Checks the possible moves for the current player and highlights those pieces.
## If there are no possible moves, then changes directly to the next player's [RollPhase]
func start():
	_calculate_legal_moves()
	
	if _legal_moves.is_empty():
		_gamemode.switch_player()
		_gamemode.changeState(RollPhase.new(_gamemode))
		return
	
	for piece in _legal_moves:
		piece.enable_selection()


## Disables highlighting of the movable pieces calculated in [method start] 
func end():
	for piece in _legal_moves:
		piece.disable_selection()


## Moves the [param piece]. If player gets an extra roll, then move to the [RollPhase] again. If player wins, then end the game.
## Otherwise, changes to the next player's [RollPhase].
func move(piece: Piece):
	var landing_spot = _gamemode.board.get_landing_spot(piece, _gamemode.dice.value)
	if landing_spot != null:
		await _gamemode.board.move(piece, landing_spot)
	
	if _gamemode.board.is_winner(_gamemode.current_player):
		_gamemode.end_game()
		return
	
	if not landing_spot.give_extra_roll:
		_gamemode.switch_player()
	
	_gamemode.changeState(RollPhase.new(_gamemode))


func _calculate_legal_moves():
	_legal_moves = []
	var pieces = _gamemode.board.get_pieces(_gamemode.current_player)
	for piece in pieces:
		var landing_spot = _gamemode.board.get_landing_spot(piece, _gamemode.dice.value)
		if landing_spot != null and not _has_player_piece(landing_spot) and not _is_protecting_opponent(landing_spot):
			_legal_moves.append(piece)


func _has_player_piece(spot: Spot) -> bool:
	return  _gamemode.board.is_occupied_by_player(spot, _gamemode.current_player)


func _is_protecting_opponent(spot: Spot) -> bool:
	var other_player_id = General.get_other_player_id(_gamemode.current_player)
	return _gamemode.board.is_occupied_by_player(spot, other_player_id) and spot.is_rosette
