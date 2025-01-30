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
	var game_config: BoardGame.Config = await _start_menu.play_pressed
	_level.start_game(game_config)
	_level.exited.connect(_on_level_exited)


func _load_level_async() -> void:
	ResourceLoader.load_threaded_request(LEVEL_SCENE_PATH, "PackedScene", true)
	_loading_level = true
	
	var status = ResourceLoader.load_threaded_get_status(LEVEL_SCENE_PATH)
	while status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		await get_tree().create_timer(0.1).timeout
		var progress = []
		status = ResourceLoader.load_threaded_get_status(LEVEL_SCENE_PATH, progress)
		print(progress)
	
	var level_scene = ResourceLoader.load_threaded_get(LEVEL_SCENE_PATH) as PackedScene
	_level = level_scene.instantiate()
	add_child(_level)
	
	# HACK: gives some time for lighting and stuff to load
	await get_tree().create_timer(1.0).timeout
	
	level_loaded.emit()
	_loading_level = false


func _on_level_exited() -> void:
	await _loading_screen.fade_in()
	_level.queue_free()
	await _load_level_async()
	await _loading_screen.fade_out()
	
	await _start_menu.show_with_fade()
	var game_config: BoardGame.Config = await _start_menu.play_pressed
	_level.start_game(game_config)
	_level.exited.connect(_on_level_exited)
