class_name Main extends Node


@export var skip_intro := false

@export var loading_screen_fade_duration: float = 0.5
@export var loading_delay: float = 1.0 ## Delay to give time for scene loading

@export_group("References")
@export var splash_screen: SplashScreen
@export var start_menu: StartMenu
@export var loading_screen: Control

@onready var level: Node3D = $Level
@onready var level_scene: PackedScene = preload("res://scenes/game.tscn")


func _ready() -> void:
	GameEvents.back_to_main_menu_pressed.connect(_on_back_to_main_menu)
	
	loading_screen.show()
	await get_tree().create_timer(loading_delay).timeout # Delay to allow loading
	loading_screen.hide()
	
	if skip_intro:
		start_menu.show()
	else:
		splash_screen.play_splash_screen_sequence()


func _on_back_to_main_menu() -> void:
	var volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	
	loading_screen.visible = true
	loading_screen.modulate.a = 0.0
	
	# Fade in loading screen and fadeout audio
	var animator = create_tween()
	animator.tween_property(loading_screen, "modulate:a", 1.0, loading_screen_fade_duration)
	_fade_audio(-80, loading_screen_fade_duration)
	await animator.finished
	
	# Reload level
	level.queue_free()
	await Engine.get_main_loop().process_frame
	level = level_scene.instantiate()
	add_child(level)
	if not level.is_node_ready():
		await level.ready
	
	await get_tree().create_timer(loading_delay).timeout # Delay to allow proper loading
	
	# Fade out loading screen and fade in audio
	animator = create_tween()
	animator.tween_property(loading_screen, "modulate:a", 0.0, loading_screen_fade_duration)
	_fade_audio(volume, loading_screen_fade_duration)
	await animator.finished
	
	loading_screen.visible = false
	
	start_menu.show_with_fade()


# Decrease audio NOTE: Not compatible with tweeners
func _fade_audio(target_volume: float, duration: float) -> void:
	var time = 0.0
	var current_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	while time < duration:
		var new_volume = lerpf(current_volume, target_volume, time / duration)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), new_volume)
		await Engine.get_main_loop().process_frame
		time += get_process_delta_time()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), target_volume)


# NOTE: ONLY FOR TESTING
func _input(event: InputEvent) -> void:
	if event is InputEventKey and OS.is_debug_build():
		if event.pressed and event.keycode == KEY_0:
			GameEvents.game_ended.emit()
