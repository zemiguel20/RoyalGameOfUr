class_name OpponentNPC
extends Node3D

signal on_opponent_ready

var talking_animation: Animation

## Amount of seconds after starting the game before the npc begins the starting dialogue. 
@export_group("Dialogue Settings")
@export var starting_dialogue_delay: float = 2.0
@export var min_time_between_dialogues: float = 5.0
@export var max_time_between_dialogues: float = 10.0
## When a reaction plays, we delay the next dialogue, 
## to prevent the dialogue interrupting the reaction or the dialogue being skipped.
@export var reaction_dialogue_delay: float = 5.0

@onready var _dialogue_system = $DialogueSystem as DialogueSystem
@onready var _animation_player = $AnimationPlayer as OpponentAnimationPlayer

var _time_until_next_dialogue: float
## Reconsider timer vs awaiting
## Pros: More control over the time
var _is_timer_active: bool


var _tutorial_categories_had: Array[DialogueSystem.Category]


func _ready():
	visible = false
	

func _process(delta):
	if not _is_timer_active or _dialogue_system.is_busy():
		return 
		
	_time_until_next_dialogue -= delta
	if _time_until_next_dialogue <= 0:
		_play_random_dialogue()


func _play_story_dialogue():
	var success = await _dialogue_system.play(DialogueSystem.Category.INTRO_STORY)
	success = await _dialogue_system.play(DialogueSystem.Category.INTRO_RULES_QUESTION)
	success = await _dialogue_system.play(DialogueSystem.Category.INTRO_GAME_START)
	## If something went wrong when playing the story dialogues, do not try to trigger a next sequence.
	if success:
		_time_until_next_dialogue = randf_range(min_time_between_dialogues, max_time_between_dialogues)
	else: 
		_is_timer_active = false


func _play_random_dialogue():
	if (_tutorial_categories_had.size() < 4):
		_time_until_next_dialogue = randf_range(min_time_between_dialogues, max_time_between_dialogues)
		return
		
	var success = await _dialogue_system.play(DialogueSystem.Category.RANDOM_CONVERSATION)
	## If something went wrong when playing the story dialogues, do not try to trigger a next sequence. 
	if success:
		_time_until_next_dialogue = randf_range(min_time_between_dialogues, max_time_between_dialogues)
	else: 
		_is_timer_active = false


func play_dialog(category: DialogueSystem.Category):
	_dialogue_system.play(category)


func play_tutorial_dialog(category: DialogueSystem.Category):
	if !_tutorial_categories_had.has(category):
		_tutorial_categories_had.append(category)
		
	if (category == DialogueSystem.Category.GAME_TUTORIAL_OPPONENT_GETS_CAPTURED \
	and _tutorial_categories_had.has(DialogueSystem.Category.GAME_TUTORIAL_PLAYER_GETS_CAPTURED)) \
	or (category == DialogueSystem.Category.GAME_TUTORIAL_PLAYER_GETS_CAPTURED \
	and _tutorial_categories_had.has(DialogueSystem.Category.GAME_TUTORIAL_OPPONENT_GETS_CAPTURED)):
		return
		
	_dialogue_system.play(category)


func _play_interruption(category):
	_time_until_next_dialogue += reaction_dialogue_delay
	await _dialogue_system.play(category)


func _on_play_pressed():
	visible = true
	await _animation_player.play_walkin()
	## Start first dialogue after a delay.
	await get_tree().create_timer(starting_dialogue_delay).timeout
	await _play_story_dialogue()
	_is_timer_active = true	
	on_opponent_ready.emit()
	
	
## Reactions for now: Knockout? Debug Button. No Moves?
func _input(event):
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_5:
		_play_interruption(DialogueSystem.Category.GAME_OPPONENT_GETS_CAPTURED)


func _on_ai_move_picker__on_suboptimal_move():
	pass # Replace with function body.


func _on_move_picker__on_opponent_piece_captured():
	pass # Replace with function body.


func _on_move_picker_on_play_tutorial_dialogue(category):
	pass # Replace with function body.
