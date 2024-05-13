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

@onready var _dialogue_system = $DialogueSystem as DialogueCollectionPlayer
@onready var _animation_player = $AnimationPlayer as AnimationPlayer

var _time_until_next_dialogue: float
## Reconsider timer vs awaiting
## Pros: More control over the time
var _is_timer_active: bool


func _ready():
	visible = false
	

func _process(delta):
	if not _is_timer_active or _dialogue_system.is_busy():
		return 
		
	_time_until_next_dialogue -= delta
	if _time_until_next_dialogue <= 0:
		start_next_dialogue()
		
		
func start_next_dialogue():
	await _dialogue_system.play_next()
	if _dialogue_system.has_next():
		_time_until_next_dialogue = randf_range(min_time_between_dialogues, max_time_between_dialogues)
	else:
		_is_timer_active = false


# Could also name this play_reaction
func _play_interruption():
	_time_until_next_dialogue += reaction_dialogue_delay
	await _dialogue_system.interrupt()
	

func _on_gamemode_rolled_zero():
	_play_interruption()
	
	
func _on_play_pressed():
	visible = true
	_animation_player.play("clip_walkIn")
	await _wait_until_animation_end()
	
	# Start first dialogue after a delay.
	await get_tree().create_timer(starting_dialogue_delay).timeout
	await start_next_dialogue()
	_is_timer_active = true	
	_play_default_idle()
	on_opponent_ready.emit()
	
	
func _play_default_idle():
	_animation_player.play("clip_breathing")
	
	
func _wait_until_animation_end():
	await get_tree().create_timer(_animation_player.current_animation_length).timeout
	
