class_name Main extends Node


@export var skip_intro := false

@export_group("References")
@export var splash_screen: SplashScreen
@export var title_screen: TitleScreen
@export var start_menu: StartMenu
@export var ruleset_menu: RulesetMenu
@export var end_screen: EndScreen


func _ready() -> void:
	GameEvents.back_to_main_menu_pressed.connect(_on_back_to_main_menu)
	
	splash_screen.visible = false
	title_screen.visible = false
	start_menu.visible = false
	ruleset_menu.visible = false
	end_screen.visible = false
	
	if not skip_intro:
		splash_screen.play_splash_screen_sequence()
		await splash_screen.sequence_finished
		title_screen.play_title_screen()
		await title_screen.pressed
	
	start_menu.visible = true


func _on_back_to_main_menu() -> void:
	start_menu.visible = true
	# NOTE: possibly add here reloading logic to reset Level


func _on_start_menu_singleplayer_selected() -> void:
	start_menu.visible = false
	
	GameManager.is_hotseat = false
	GameManager.is_rematch = false
	GameManager.ruleset = General.RULESET_FINKEL
	GameManager.start_new_game()
	GameEvents.play_pressed.emit()


func _on_start_menu_multiplayer_selected() -> void:
	start_menu.visible = false
	ruleset_menu.visible = true


func _on_ruleset_menu_back_pressed() -> void:
	ruleset_menu.visible = false
	start_menu.visible = true


func _on_ruleset_menu_confirm_pressed(final_ruleset: Ruleset) -> void:
	ruleset_menu.visible = false
	
	GameManager.ruleset = final_ruleset
	GameManager.is_hotseat = true
	GameManager.is_rematch = false
	GameManager.start_new_game()
	GameEvents.play_pressed.emit()
