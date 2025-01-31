class_name Level
extends Node


signal exited

@onready var _board_game: BoardGame = $BoardGame
@onready var _game_camera: GameCamera = $GameCamera
@onready var _opponent: OpponentNPC = $Opponent_Guard_Animated
@onready var _ambient_audio: AmbientAudioController = $AmbientAudio
@onready var _end_screen: EndScreen = $EndScreen

@onready var _start_pov: Camera3D = $CameraPOVS/StartPOV
@onready var _singleplayer_intro_pov: Camera3D = $CameraPOVS/SingleplayerIntroPOV
@onready var _singleplayer_game_pov: Camera3D = $CameraPOVS/SingleplayerGamePOV
@onready var _hotseat_pov: Camera3D = $CameraPOVS/HotseatPOV



func _ready() -> void:
	_game_camera.move_to_POV(_start_pov.global_transform)
	_game_camera.can_look_around = false
	_opponent.visible = false
	_opponent.init(_board_game)
	_end_screen.hide()
	
	_board_game.ended.connect(_on_game_ended)
	_end_screen.rematch_pressed.connect(_on_rematch_requested)
	_end_screen.exit_pressed.connect(_on_exit_requested)


func start_game(config: BoardGame.Config) -> void:
	_board_game.setup(config)
	
	if config.hotseat:
		_game_camera.move_to_POV(_hotseat_pov.global_transform)
	else:
		_game_camera.move_to_POV(_singleplayer_intro_pov.global_transform)
		_opponent.visible = true
		_opponent.play_intro_sequence()
		await _opponent.intro_opponent_sat_down
		_game_camera.move_to_POV(_singleplayer_game_pov.global_transform)
		await _opponent.intro_finished
		_opponent.enable_reactions()
		_game_camera.can_look_around = true
	
	_board_game.start()


func _on_game_ended(winner: BoardGame.Player) -> void:
	if not _board_game.config.hotseat:
		_opponent.stop()
	_end_screen.show_end_menu(winner, _board_game.config.hotseat)


func _on_rematch_requested() -> void:
	_board_game.config.rematch = true
	_board_game.setup(_board_game.config)
	if not _board_game.config.hotseat:
		_opponent.enable_reactions()
	_board_game.start()


func _on_exit_requested() -> void:
	if not _board_game.config.hotseat:
		_opponent.stop()
	_game_camera.move_to_POV(_start_pov.global_transform)
	_ambient_audio.fade_out_audio()
	exited.emit()
