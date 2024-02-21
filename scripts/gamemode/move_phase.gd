class_name MovePhase
extends Phase


var _legal_moves


func start():
	var player_id = _gamemode.current_player
	var roll_value = _gamemode.dice.value
	_legal_moves = _gamemode.board.legal_moves(player_id, roll_value)
	
	if _legal_moves.is_empty():
		_gamemode._switch_player()
		_gamemode._changeState(RollPhase.new(_gamemode))
		return
	
	for piece in _legal_moves:
		piece.enable_selection()


func move(piece: Piece):
	# TODO: IMPLEMENT MOVING
	pass
