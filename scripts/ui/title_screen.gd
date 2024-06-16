class_name TitleScreen extends CanvasLayer


signal pressed

@export var fade_duration := 0.5

@export_group("References")
@export var game_title_logo: TextureRect
@export var press_to_start_label: Label


func play_title_screen() -> void:
	visible = true
	game_title_logo.modulate.a = 0.0
	press_to_start_label.modulate.a = 0.0
	
	var animator = create_tween()
	animator.tween_property(game_title_logo, "modulate:a", 1.0, fade_duration)
	await animator.finished
	
	# Bit of idle time just to EXPOSE THE LOGO AND ITS GREATNESS AHAHAHAHAHAHA
	await get_tree().create_timer(0.5).timeout
	
	press_to_start_label.modulate.a = 1.0
	
	while not Input.is_action_pressed("advance_screen"):
			await Engine.get_main_loop().process_frame
	
	visible = false
	
	pressed.emit()
