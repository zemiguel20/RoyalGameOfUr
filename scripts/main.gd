extends Node


signal level_loaded

const LEVEL_SCENE_PATH: String = "res://scenes/game.tscn"

@export var _skip_intro := false

var _level: Level
var _loading_level: bool = false

@onready var _splash_screen: SplashScreen = $SplashScreen
@onready var _title_screen: TitleScreen = $TitleScreen
@onready var _loading_screen: LoadingScreen = $LoadingScreen
@onready var _start_menu: StartMenu = $StartMenu


func _ready() -> void:
	# INFO: The level is loading during the splash screen
	
	_load_level_async()
	_loading_screen.show()
	
	_start_menu.hide()
	
	if not _skip_intro:
		_splash_screen.play()
		await _splash_screen.finished
	
	if _loading_level:
		await level_loaded
	
	await _loading_screen.fade_out()
	
	_title_screen.play()
	await _title_screen.pressed
	
	_start_menu.show()
	var game_config = await _start_menu.play_pressed
	
	_start_menu.hide()
	_level.start_game(game_config)


func _load_level_async() -> void:
	ResourceLoader.load_threaded_request(LEVEL_SCENE_PATH, "PackedScene", true)
	_loading_level = true
	
	var status = ResourceLoader.load_threaded_get_status(LEVEL_SCENE_PATH)
	while status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		await get_tree().create_timer(0.1).timeout
		status = ResourceLoader.load_threaded_get_status(LEVEL_SCENE_PATH)
	
	var level_scene = ResourceLoader.load_threaded_get(LEVEL_SCENE_PATH) as PackedScene
	_level = level_scene.instantiate()
	add_child(_level)
	
	# HACK: gives some time for lighting and stuff to load
	await get_tree().create_timer(1.0).timeout
	
	level_loaded.emit()
	_loading_level = false


#func _on_back_to_main_menu() -> void:
	#var volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	#
	#loading_screen.visible = true
	#loading_screen.modulate.a = 0.0
	#
	## Fade in loading screen and fadeout audio
	#var animator = create_tween()
	#animator.tween_property(loading_screen, "modulate:a", 1.0, loading_screen_fade_duration)
	#_fade_audio(-80, loading_screen_fade_duration)
	#await animator.finished
	#
	## Reload level
	#level.queue_free()
	#await Engine.get_main_loop().process_frame
	#level = level_scene.instantiate()
	#add_child(level)
	#if not level.is_node_ready():
		#await level.ready
	#
	#await get_tree().create_timer(loading_delay).timeout # Delay to allow proper loading
	#
	## Fade out loading screen and fade in audio
	#animator = create_tween()
	#animator.tween_property(loading_screen, "modulate:a", 0.0, loading_screen_fade_duration)
	#_fade_audio(volume, loading_screen_fade_duration)
	#await animator.finished
	#
	#loading_screen.visible = false
	#
	#start_menu.show_with_fade()


# NOTE: ONLY FOR TESTING
func _input(event: InputEvent) -> void:
	if event is InputEventKey and OS.is_debug_build():
		if event.pressed and event.keycode == KEY_0:
			GameEvents.game_ended.emit()
