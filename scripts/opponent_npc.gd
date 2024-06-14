class_name OpponentNPC extends Node3D


@export var skip_intro: bool
@export var starting_dialogue_delay: float = 1.0
@export var min_time_between_dialogues: float = 5.0
@export var max_time_between_dialogues: float = 10.0

var explained_rosettes_extra_roll: bool
var explained_rosettes_are_safe: bool
var explained_capturing: bool
var explained_securing: bool
var explained_everything: bool

@export var _dialogue_system: DialogueSystem
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dialogue_cooldown_timer: Timer = $DialogueCooldownTimer


func _ready():
	visible = false
	GameEvents.play_pressed.connect(_on_play_pressed)
	# DialogueSystem should play opponent animations.
	# NOTE: Actually not, they should stay separate and this script should coordinate
	# between animations and dialogue, but whatever...
	_dialogue_system.set_animation_player(animation_player)


func _on_play_pressed() -> void:
	# TODO: Disconnect ALL SIGNALS
	
	# Opponent only
	if GameManager.is_hotseat:
		visible = false
		return
	
	visible = true
	
	GameEvents.rolled.connect(_on_dice_rolled)
	GameEvents.first_turn_dice_shake.connect(_on_first_turn_dice_shaked)
	GameEvents.npc_selected_move.connect(_on_npc_selected_move)
	GameEvents.move_hovered.connect(_on_move_hovered)
	GameEvents.move_executed.connect(_on_move_executed)
	GameEvents.opponent_thinking.connect(_try_play_thinking_sound)
	dialogue_cooldown_timer.timeout.connect(_on_dialogue_cooldown_timer_timeout)
	
	if not GameManager.is_rematch:
		_play_walk_in_sequence()
		await GameEvents.intro_sequence_finished
	
	GameEvents.opponent_ready.emit()


func _on_dice_rolled(value: int) -> void:
	if explained_everything and value == 0 and GameManager.current_player == General.Player.TWO \
	and GameManager.turn_number > 5:
		_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_ROLLED_0)


func _on_first_turn_dice_shaked():
	if not explained_everything: return
	
	_dialogue_system.play(DialogueSystem.Category.INTRO_GOOD_LUCK_WISH)
	if GameManager.is_rematch:
		_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_ROLL_FOR_HOPE)


func _on_npc_selected_move(move: GameMove) -> void:
	if not GameManager.is_rematch:
		_try_play_tutorial_dialog(move)


func _on_move_hovered(move: GameMove) -> void:
	if not GameManager.is_rematch:
		_try_play_tutorial_dialog(move)


func _on_move_executed(move: GameMove) -> void:
	if move.is_to_occupied_by_opponent:
		_try_play_capture_reaction_dialogue(move)


func _on_dialogue_cooldown_timer_timeout() -> void:
	_play_random_dialogue()


func _play_walk_in_sequence() -> void:
	GameEvents.intro_sequence_started.emit()
	
	if skip_intro:
		animation_player.play("clip_walkIn", 0)
		animation_player.seek(30)
		await Engine.get_main_loop().process_frame
		GameEvents.opponent_seated.emit()
		await Engine.get_main_loop().process_frame
	else:
		animation_player.play("clip_walkIn", 0)
		await animation_player.animation_finished
		await get_tree().create_timer(starting_dialogue_delay).timeout
		await _dialogue_system.play(DialogueSystem.Category.INTRO_STORY)
		GameEvents.opponent_seated.emit()
		await _dialogue_system.play(DialogueSystem.Category.INTRO_GAME_START)
	
	GameEvents.intro_sequence_finished.emit()
	
	var dialogue_cd_time = randf_range(min_time_between_dialogues, max_time_between_dialogues)
	dialogue_cooldown_timer.start(dialogue_cd_time)


func _play_random_dialogue():
	if not explained_everything:
		## Try again after 10 seconds.
		dialogue_cooldown_timer.start(10)
		return
		
	await _dialogue_system.play(DialogueSystem.Category.RANDOM_CONVERSATION)
	var dialogue_cd_time = randf_range(min_time_between_dialogues, max_time_between_dialogues)
	dialogue_cooldown_timer.start(dialogue_cd_time)


func _try_play_tutorial_dialog(move: GameMove):
	#if Settings.check_ruleset(Settings.Ruleset.FINKEL): return
	if explained_everything: return
		
	if not explained_capturing and move.is_to_occupied_by_opponent:
		if move.player == General.Player.TWO:
			_dialogue_system.play(DialogueSystem.Category.TUTORIAL_PLAYER_GETS_CAPTURED)
		else:
			_dialogue_system.play(DialogueSystem.Category.TUTORIAL_OPPONENT_GETS_CAPTURED)
		explained_capturing = true
		return
	
	if not explained_rosettes_extra_roll and move.gives_extra_turn:
		_dialogue_system.play(DialogueSystem.Category.TUTORIAL_ROSETTE)
		explained_rosettes_extra_roll = true
		return
	
	if not explained_rosettes_are_safe and move.is_to_safe and move.is_to_shared:
		_dialogue_system.play(DialogueSystem.Category.TUTORIAL_CENTRAL_ROSETTE)
		explained_rosettes_are_safe = true
		return
	
	var from_index = EntityManager.get_board().get_track(move.player).find(move.from)
	if not explained_securing and from_index > 7:
		_dialogue_system.play(DialogueSystem.Category.TUTORIAL_FINISH)
		explained_securing = true
		return
	
	if has_explained_everything() and not _dialogue_system.is_busy():
		_dialogue_system.play(DialogueSystem.Category.TUTORIAL_THATS_ALL)
		explained_everything = true


func has_explained_everything() -> bool:
	return explained_rosettes_extra_roll and explained_capturing \
	and explained_rosettes_are_safe and explained_securing


func _try_play_thinking_sound():
	_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_THINKING)


func _try_play_capture_reaction_dialogue(move: GameMove):
	if not has_explained_everything: return
	
	# Play a stronger reaction if the piece was further ahead,
	# or if the roll was high (i.e. someone got lucky)
	var to_index = EntityManager.get_board().get_track(move.player).find(move.to)
	var was_piece_far = to_index >= 8
	var rolled_3_plus = move.full_path.size()-1 >= 3
	var rolled_4 = move.full_path.size()-1 >= 4
	if move.player == General.Player.TWO:
		if (was_piece_far and rolled_3_plus) or move.pieces_in_to.size() > 1:
			_dialogue_system.play(DialogueSystem.Category.GAME_PLAYER_GETS_CAPTURED)
		elif was_piece_far or rolled_4:
			_dialogue_system.play(DialogueSystem.Category.GAME_PLAYER_MISTAKE)
	else:
		if (was_piece_far and rolled_3_plus) or move.pieces_in_to.size() > 1:
			_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_GETS_CAPTURED)
		elif was_piece_far or rolled_4:
			_dialogue_system.play(DialogueSystem.Category.GAME_OPPONENT_MISTAKE)
