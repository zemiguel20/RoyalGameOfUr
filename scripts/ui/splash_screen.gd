class_name SplashScreen
extends CanvasLayer


signal finished

@export var _test: bool = false
@export var _fade_duration := 0.5
@export var _pause_duration := 1.0

@onready var _godot_logo: TextureRect = $GodotLogo
@onready var _entities_logos: Control = $EntitiesLogos
@onready var _background: ColorRect = $Background


func _ready() -> void:
	visible = false
	
	if _test:
		await Engine.get_main_loop().process_frame
		play()


func play() -> void:
	visible = true
	_godot_logo.modulate.a = 0.0
	_entities_logos.modulate.a = 0.0
	
	var animator: Tween
	
	animator = create_tween()
	animator.tween_property(_entities_logos, "modulate:a", 1.0, _fade_duration)
	await animator.finished
	
	await _skippable_pause(_pause_duration)
	
	animator = create_tween()
	animator.tween_property(_entities_logos, "modulate:a", 0.0, _fade_duration)
	animator.tween_property(_godot_logo, "modulate:a", 1.0, _fade_duration)
	await animator.finished
	
	await _skippable_pause(_pause_duration)
	
	animator = create_tween()
	animator.tween_property(_godot_logo, "modulate:a", 0.0, _fade_duration)
	await animator.finished
	
	animator = create_tween()
	animator.tween_property(_background, "modulate:a", 0.0, _fade_duration)
	await animator.finished
	
	visible = false
	
	finished.emit()


func _skippable_pause(duration := 0.0) -> void:
		var timer = get_tree().create_timer(duration)
		while timer.time_left > 0 and not Input.is_action_pressed("advance_screen"):
			await Engine.get_main_loop().process_frame
