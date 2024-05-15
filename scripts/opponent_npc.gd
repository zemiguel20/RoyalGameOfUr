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


func _ready():
	visible = false
	#_animation_player.play_talking()
	

func _process(delta):
	if not _is_timer_active or _dialogue_system.is_busy():
		return 
		
	_time_until_next_dialogue -= delta
	if _time_until_next_dialogue <= 0:
		_play_story_dialogue()
	

# Could also name this play_reaction
func _play_interruption():
	_time_until_next_dialogue += reaction_dialogue_delay
	await _dialogue_system.interrupt()
	
	
func _play_story_dialogue():
	var success = await _dialogue_system.play(DialogueSystem.Category.STORY)
	## If something went wrong when playing the story dialogues, do not try to trigger a next sequence. 
	if success:
		_time_until_next_dialogue = randf_range(min_time_between_dialogues, max_time_between_dialogues)
	else: 
		_is_timer_active = false
	

func _on_gamemode_rolled_zero():
	_play_interruption()
	
	
func _on_play_pressed():
	visible = true
	await _animation_player.play_animation(OpponentAnimationPlayer.Anim_Name.WALKIN, true)
	## Start first dialogue after a delay.
	await get_tree().create_timer(starting_dialogue_delay).timeout
	await _play_story_dialogue()
	_is_timer_active = true	
	on_opponent_ready.emit()
	
