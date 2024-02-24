class_name MovePhase
extends Phase
## Rolling phase of the [Gamemode]. Implements behaviour for the piece move action.


var _legal_moves


## Checks the possible moves for the current player and highlights those pieces.
## If there are no possible moves, then changes directly to the next player's [RollPhase]
func start():
	var player_id = _gamemode.current_player
	var roll_value = _gamemode.dice.value
	_legal_moves = _gamemode.board.legal_moves(player_id, roll_value)
	
	if _legal_moves.is_empty():
		_gamemode.switch_player()
		_gamemode.changeState(RollPhase.new(_gamemode))
		return
	
	for piece in _legal_moves:
		piece.enable_highlight()


## Disables highlighting of the movable pieces calculated in [method start] 
func end():
	for piece in _legal_moves:
		piece.disable_highlight()


## Moves the [param piece]. If player gets an extra roll, then move to the [RollPhase] again. If player wins, then end the game.
## Otherwise, changes to the next player's [RollPhase].
func move(piece: Piece):
	var result = await _gamemode.board.move(piece, _gamemode.dice.value)
	if result == General.Result.EXTRA_ROLL:
		_gamemode.changeState(RollPhase.new(_gamemode))
	elif result == General.Result.WON:
		_gamemode.end_game()
	else:
		_gamemode.switch_player()
		_gamemode.changeState(RollPhase.new(_gamemode))
