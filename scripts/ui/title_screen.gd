class_name TitleScreen
extends CanvasLayer


signal pressed

@export var test: bool = false
@export var fade_duration := 0.5

@onready var _game_title_logo: TextureRect = $Control/GameTitleLogo
@onready var _press_to_start_label: Label = $Control/PressToStartLabel


func _ready() -> void:
	visible = false
	
	if test:
		await Engine.get_main_loop().process_frame
		play()


func play() -> void:
	visible = true
	_game_title_logo.modulate.a = 0.0
	_press_to_start_label.modulate.a = 0.0
	
	var animator = create_tween()
	animator.tween_property(_game_title_logo, "modulate:a", 1.0, fade_duration)
	await animator.finished
	
	# Bit of idle time just to EXPOSE THE LOGO AND ITS GREATNESS AHAHAHAHAHAHA
	await get_tree().create_timer(fade_duration / 2).timeout
	
	animator = create_tween()
	animator.tween_property(_press_to_start_label, "modulate:a", 1.0, fade_duration / 2)
	await animator.finished
	
	while not Input.is_action_pressed("advance_screen"):
		await Engine.get_main_loop().process_frame
	
	visible = false
	
	pressed.emit()
