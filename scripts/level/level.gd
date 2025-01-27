class_name Level
extends Node


@onready var _board_game: BoardGame = $BoardGame
@onready var _game_camera: GameCamera = $GameCamera
@onready var _opponent: OpponentNPC = $Opponent_Guard_Animated

@onready var _start_pov: Camera3D = $CameraPOVS/StartPOV
@onready var _singleplayer_intro_pov: Camera3D = $CameraPOVS/SingleplayerIntroPOV
@onready var _singleplayer_game_pov: Camera3D = $CameraPOVS/SingleplayerGamePOV
@onready var _hotseat_pov: Camera3D = $CameraPOVS/HotseatPOV


func _ready() -> void:
	_game_camera.move_to_POV(_start_pov.global_transform)
	_game_camera.can_look_around = false
	_opponent.visible = false
	_opponent.init(_board_game)


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
	
	_board_game.start()
