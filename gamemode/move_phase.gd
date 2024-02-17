class_name MovePhase
extends Phase


var _legal_moves


func start():
	_legal_moves = _gamemode._calculate_legal_moves()
	if _legal_moves.is_empty():
		print("No moves available. Skipping turn...")
		_gamemode._switch_player()
		_gamemode._changeState(RollPhase.new(_gamemode))
	await _gamemode.get_tree().create_timer(5.0).timeout
	
