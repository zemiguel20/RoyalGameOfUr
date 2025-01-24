class_name StartMenu
extends CanvasLayer


signal play_pressed(config: BoardGame.Config)

@export var test: bool = false
@export var fade_duration: float = 0.5 ## Duration of fading in for each element
@export var show_buttons_delay: float = 0.5 ## Delay until fading in buttons

@onready var _menu_background: TextureRect = $MainMenu/MenuBackground
@onready var _game_title_banner: TextureRect = $MainMenu/GameTitleBanner
@onready var _button_list: VBoxContainer = $MainMenu/Buttons
@onready var _singleplayer_button: Button = $MainMenu/Buttons/SingleplayerButton
@onready var _multiplayer_button: Button = $MainMenu/Buttons/MultiplayerButton
@onready var _quit_button: Button = $MainMenu/Buttons/QuitButton
@onready var _game_version_label: Label = $MainMenu/GameVersionLabel

@onready var _ruleset_menu: RulesetMenu = $RulesetMenu


func _ready() -> void:
	_game_version_label.text = "ver " + ProjectSettings.get_setting("application/config/version")
	
	_singleplayer_button.pressed.connect(_start_singleplayer_game)
	_multiplayer_button.pressed.connect(_show_ruleset_menu)
	_quit_button.pressed.connect(_quit_game)
	
	_ruleset_menu.back_pressed.connect(_show_main_menu)
	_ruleset_menu.play_pressed.connect(play_pressed.emit)
	
	if test:
		await Engine.get_main_loop().process_frame # loading
		show_with_fade()
	else:
		_show_main_menu()


func show_with_fade() -> void:
	_show_main_menu()
	_menu_background.modulate.a = 0.0
	_game_title_banner.modulate.a = 0.0
	_button_list.modulate.a = 0.0
	_button_list.visible = false # NOTE: this disables buttons
	
	var background_animator = create_tween()
	background_animator.tween_property(_menu_background, "modulate:a", 1.0, fade_duration)
	await  background_animator.finished
	
	var logo_animator = create_tween()
	logo_animator.tween_property(_game_title_banner, "modulate:a", 1.0, fade_duration)
	await logo_animator.finished
	
	await get_tree().create_timer(show_buttons_delay).timeout
	
	var buttons_animator = create_tween()
	_button_list.visible = true
	buttons_animator.tween_property(_button_list, "modulate:a", 1.0, fade_duration)


func _show_main_menu() -> void:
	show()
	_ruleset_menu.hide()


func _start_singleplayer_game() -> void:
	hide()
	var config := BoardGame.Config.new() # Default values are for singleplayer
	play_pressed.emit(config)


func _show_ruleset_menu() -> void:
	hide()
	_ruleset_menu.show()


func _quit_game() -> void:
	get_tree().quit()
