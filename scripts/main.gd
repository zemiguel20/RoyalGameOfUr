extends Node


signal level_loaded

@export var _skip_intro := false

var _level: Level
var _loading_thread: Thread
var _loading_level: bool = false

@onready var _splash_screen: SplashScreen = $SplashScreen
@onready var _title_screen: TitleScreen = $TitleScreen
@onready var _loading_screen: LoadingScreen = $LoadingScreen
@onready var _start_menu: StartMenu = $StartMenu


func _ready() -> void:
	# INFO: The level is loading during the splash screen
	_loading_thread = Thread.new()
	
	_start_menu.hide()
	
	_load_level_async()
	
	if not _skip_intro:
		_splash_screen.play()
		await _splash_screen.finished
	
	if _loading_level:
		await level_loaded
	
	_title_screen.play()
	await _title_screen.pressed
	
	_start_menu.show()


func _load_level_async() -> void:
	_loading_level = false
	
	await _loading_screen.fade_in()
	
	if _level != null:
		_level.queue_free()
	
	_loading_thread.start(_instantiate_level)
	while _loading_thread.is_alive():
		await get_tree().create_timer(0.1).timeout
	_level = _loading_thread.wait_to_finish() as Level
	
	add_child(_level)
	await get_tree().create_timer(1.0).timeout # Guaratees some extra time to load lighting and stuff
	
	_start_menu.play_pressed.connect(_level.start_game)
	_level.exited.connect(_on_level_exited)
	
	await _loading_screen.fade_out()
	level_loaded.emit()
	_loading_level = false


func _instantiate_level() -> Level:
	var level_scene = preload("res://scenes/game.tscn") as PackedScene
	var level = level_scene.instantiate() as Level
	return level


func _on_level_exited() -> void:
	await _load_level_async()
	await _start_menu.show_with_fade()
