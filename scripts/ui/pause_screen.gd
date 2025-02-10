class_name PauseMenu
extends CanvasLayer


signal paused
signal resume_pressed
signal quit_pressed

## Allows controlling when pausing is allowed.
## Pausing is not desirable for example in the intro or in the menus.
var can_pause: bool = false

var _is_paused: bool = false

@onready var _resume_button: Button = $TabletPanel/Buttons/ResumeButton
@onready var _main_menu_button: Button = $TabletPanel/Buttons/MainMenuButton
@onready var _settings_button: Button = $TabletPanel/Buttons/SettingsButton
@onready var _settings_menu: SettingsMenu = $SettingsMenu


func _ready():
	_settings_menu.hide()
	
	_resume_button.pressed.connect(_on_resume_pressed)
	_main_menu_button.pressed.connect(_on_quit_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_settings_menu.back_pressed.connect(_on_settings_back_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause"):
		if not _is_paused and can_pause:
			_pause()
		elif _is_paused:
			_on_resume_pressed()


func _pause() -> void:
	_is_paused = true
	Engine.time_scale = 0
	paused.emit()


func _resume() -> void:
	_is_paused = false
	Engine.time_scale = 1


func _on_resume_pressed():
	_resume()
	resume_pressed.emit()


func _on_quit_pressed():
	_resume()
	quit_pressed.emit()


func _on_settings_pressed():
	hide()
	_settings_menu.show()


func _on_settings_back_pressed():
	show()
	_settings_menu.hide()
