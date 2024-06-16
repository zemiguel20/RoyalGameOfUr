class_name SplashScreen extends CanvasLayer


signal sequence_finished

@export var fade_duration := 0.5
@export var pause_duration := 1.0

@export_group("References")
@export var background: Control 
@export var entities_logos: Control
@export var godot_logo: TextureRect


func play_splash_screen_sequence() -> void:
	visible = true
	background.modulate.a = 1.0
	godot_logo.modulate.a = 0.0
	entities_logos.modulate.a = 0.0
	
	# Idle time to load
	await get_tree().create_timer(0.5).timeout
	
	var animator: Tween
	
	# Fade in team and school logos
	animator = create_tween()
	animator.tween_property(entities_logos, "modulate:a", 1.0, fade_duration)
	await animator.finished
	
	await _skippable_pause(pause_duration)
	
	# Fade out entities and fade in Godot logo
	animator = create_tween()
	animator.tween_property(entities_logos, "modulate:a", 0.0, fade_duration)
	animator.tween_property(godot_logo, "modulate:a", 1.0, fade_duration)
	await animator.finished
	
	await _skippable_pause(pause_duration)
	
	# Fade out Godot logo and then background
	animator = create_tween()
	animator.tween_property(godot_logo, "modulate:a", 0.0, fade_duration)
	animator.tween_property(background, "modulate:a", 0.0, fade_duration)
	await animator.finished
	
	visible = false
	
	sequence_finished.emit()


func _skippable_pause(duration := 0.0) -> void:
		var timer = get_tree().create_timer(duration)
		while timer.time_left > 0 and not Input.is_action_pressed("advance_screen"):
			await Engine.get_main_loop().process_frame
