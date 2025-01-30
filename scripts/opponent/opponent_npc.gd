class_name OpponentNPC
extends Node3D
## Coordinates the opponent animations and dialogue to what is happening in the game.
##
## NOTE: tutorial only works with Finkel ruleset 

signal intro_opponent_sat_down
signal intro_finished

@export var skip_intro: bool
@export var starting_dialogue_delay: float = 1.0
@export var min_time_between_dialogues: float = 5.0
@export var max_time_between_dialogues: float = 10.0

# TODO: maybe add a skip tutorial parameter to a init() function.
# This can be set in the menu through a button
var _explained_everything: bool = false
var _explained_knockout: bool = false
var _explained_rosettes_extra_roll: bool = false
var _explained_rosettes_are_safe: bool = false
var _explained_finish: bool = false

var _game: BoardGame

var _reacting: bool = false

@onready var _dialogue_system: DialogueSystem = $DialogueSystem
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _dialogue_cooldown_timer: Timer = $DialogueCooldownTimer


func _ready() -> void:
	_dialogue_system.set_animation_player(_animation_player)


func init(board_game: BoardGame) -> void:
	_game = board_game


func play_intro_sequence() -> void:
	visible = true
	
	if skip_intro:
		_animation_player.play("clip_walkIn", 0)
		_animation_player.seek(30)
		await Engine.get_main_loop().process_frame
		intro_opponent_sat_down.emit()
		await Engine.get_main_loop().process_frame
	else:
		_animation_player.play("clip_walkIn", 0)
		await _animation_player.animation_finished
		await get_tree().create_timer(starting_dialogue_delay).timeout
		await _dialogue_system.play(DialogueSystem.Category.INTRO_STORY)
		intro_opponent_sat_down.emit()
		await _dialogue_system.play(DialogueSystem.Category.INTRO_GAME_START)
	
	intro_finished.emit()


func enable_reactions() -> void:
	if _reacting:
		return
	
	var p1_roll_controller: InteractiveRollController = _game.p1_turn_controller.roll_controller
	var p2_roll_controller: AutoRollController = _game.p2_turn_controller.roll_controller
	var p1_move_selector: InteractiveGameMoveSelector = _game.p1_turn_controller.move_selector
	var p2_move_selector: AIGameMoveSelector = _game.p2_turn_controller.move_selector
	
	p1_roll_controller.rolled.connect(_on_dice_rolled)
	p2_roll_controller.rolled.connect(_on_dice_rolled)
	
	p1_roll_controller.shake_started.connect(_on_dice_shaked)
	p2_roll_controller.shake_started.connect(_on_dice_shaked)
	
	p1_move_selector.from_spot_hovered.connect(_on_move_from_hovered)
	
	p1_move_selector.move_selected.connect(_on_selected_move)
	p2_move_selector.move_selected.connect(_on_selected_move)
	
	p2_move_selector.extra_thinking_needed.connect(_try_play_thinking_sound)
	
	_dialogue_cooldown_timer.timeout.connect(_play_random_dialogue)
	
	_reacting = true


func disable_reactions() -> void:
	if not _reacting:
		return
	
	var p1_roll_controller: InteractiveRollController = _game.p1_turn_controller.roll_controller
	var p2_roll_controller: AutoRollController = _game.p2_turn_controller.roll_controller
	var p1_move_selector: InteractiveGameMoveSelector = _game.p1_turn_controller.move_selector
	var p2_move_selector: AIGameMoveSelector = _game.p2_turn_controller.move_selector
	
	p1_roll_controller.rolled.disconnect(_on_dice_rolled)
	p2_roll_controller.rolled.disconnect(_on_dice_rolled)
	
	p1_roll_controller.shake_started.disconnect(_on_dice_shaked)
	p2_roll_controller.shake_started.disconnect(_on_dice_shaked)
	
	p1_move_selector.from_spot_hovered.disconnect(_on_move_from_hovered)
	
	p1_move_selector.move_selected.disconnect(_on_selected_move)
	p2_move_selector.move_selected.disconnect(_on_selected_move)
	
	p2_move_selector.extra_thinking_needed.disconnect(_try_play_thinking_sound)
	
	_dialogue_cooldown_timer.timeout.disconnect(_play_random_dialogue)
	
	_reacting = false


func stop() -> void:
	_animation_player.stop()
	_dialogue_system.stop()
	disable_reactions()


func _on_dice_rolled(value: int) -> void:
	if _explained_everything and value == 0 and _game.turn_number > 5:
		if _game.current_player == BoardGame.Player.TWO:
			_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_ROLLED_0)
		else:
			_dialogue_system.play(DialogueSystem.Category.GAME_PLAYER_MISTAKE)


func _on_dice_shaked():
	if _game.turn_number == 1 and _game.config.rematch:
		if randi_range(0, 1) == 1:
			_dialogue_system.play(DialogueSystem.Category.INTRO_GOOD_LUCK_WISH)
		else:
			_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_ROLL_FOR_HOPE)
#
#
func _on_selected_move(move: GameMove) -> void:
	if not _game.config.rematch:
		_try_play_tutorial_dialog(move)
	elif move.knocks_opponent_out:
		_try_play_capture_reaction_dialogue(move)


func _on_move_from_hovered(moves_from: Array[GameMove]) -> void:
	if not _game.config.rematch:
		_try_play_tutorial_dialog(moves_from.front())


func _try_play_tutorial_dialog(move: GameMove):
	if _explained_everything:
		return
		
	if not _explained_knockout and move.knocks_opponent_out:
		if move.player == BoardGame.Player.TWO:
			_dialogue_system.play(DialogueSystem.Category.TUTORIAL_PLAYER_GETS_CAPTURED)
		else:
			_dialogue_system.play(DialogueSystem.Category.TUTORIAL_OPPONENT_GETS_CAPTURED)
		_explained_knockout = true
		return
	
	if not _explained_rosettes_extra_roll and move.gives_extra_turn:
		_dialogue_system.play(DialogueSystem.Category.TUTORIAL_ROSETTE)
		_explained_rosettes_extra_roll = true
		return
	
	if not _explained_rosettes_are_safe and move.to_is_safe and move.to_is_shared:
		_dialogue_system.play(DialogueSystem.Category.TUTORIAL_CENTRAL_ROSETTE)
		_explained_rosettes_are_safe = true
		return
	
	if not _explained_finish and move.from_track_index > 7:
		_dialogue_system.play(DialogueSystem.Category.TUTORIAL_FINISH)
		_explained_finish = true
		return
	
	_explained_everything = _explained_knockout and _explained_rosettes_extra_roll \
							and _explained_rosettes_are_safe and _explained_finish
	if _explained_everything and not _dialogue_system.is_busy():
		_dialogue_system.play(DialogueSystem.Category.TUTORIAL_THATS_ALL)
		_dialogue_cooldown_timer.start(10)


func _try_play_capture_reaction_dialogue(move: GameMove):
	if not _explained_everything:
		return
	
	# Play a stronger reaction if the piece was further ahead,
	# or if the roll was high (i.e. someone got lucky)
	var was_piece_far = move.to_track_index >= 8
	var rolled_not_2 = move.full_path.size() - 1 != 2
	var rolled_4 = move.full_path.size() - 1 == 4
	var captured_stack = move.pieces_in_to.size() > 1
	var player_almost_wins = _determine_pieces_left(BoardGame.Player.ONE) <= 3
	var opponent_almost_wins = _determine_pieces_left(BoardGame.Player.TWO) <= 3
	if move.player == BoardGame.Player.TWO:
		if (was_piece_far and rolled_not_2) or captured_stack or player_almost_wins:
			_dialogue_system.play(DialogueSystem.Category.GAME_PLAYER_GETS_CAPTURED)
		elif (was_piece_far or rolled_4) or randi_range(0, 3) == 1:
			_dialogue_system.play(DialogueSystem.Category.GAME_PLAYER_MISTAKE)
	else:
		if (was_piece_far and rolled_not_2) or captured_stack or opponent_almost_wins or player_almost_wins:
			_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_GETS_CAPTURED)
		elif (was_piece_far or rolled_4) or randi_range(0, 3) == 1:
			_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_MISTAKE)


func _determine_pieces_left(player: int) -> int:
	return _game.config.ruleset.num_pieces - _game.board.get_player_number_of_pieces_in_end(player)


func _try_play_thinking_sound():
	_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_THINKING)


func _play_random_dialogue():	
	await _dialogue_system.play(DialogueSystem.Category.RANDOM_CONVERSATION)
	var dialogue_cd_time = randf_range(min_time_between_dialogues, max_time_between_dialogues)
	_dialogue_cooldown_timer.start(dialogue_cd_time)
