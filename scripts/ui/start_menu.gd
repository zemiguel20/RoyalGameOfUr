class_name StartMenu extends CanvasLayer


signal multiplayer_selected

@export var test: bool = false
@export var fade_duration: float = 0.5 ## Duration of fading in for each element
@export var show_buttons_delay: float = 0.5 ## Delay until fading in buttons

@export_group("References")
@export var root: Control
@export var background: Control
@export var game_logo: Control
@export var button_list: Control
@export var game_version_label: Label


func _ready() -> void:
	visible = false
	game_version_label.text = "ver " + ProjectSettings.get_setting("application/config/version")
	
	if test:
		await Engine.get_main_loop().process_frame # loading
		show_with_fade()


func show_with_fade() -> void:
	visible = true
	background.modulate.a = 0.0
	game_logo.modulate.a = 0.0
	button_list.modulate.a = 0.0
	button_list.visible = false # this disables buttons
	
	var background_animator = create_tween()
	background_animator.tween_property(background, "modulate:a", 1.0, fade_duration)
	await  background_animator.finished
	
	var logo_animator = create_tween()
	logo_animator.tween_property(game_logo, "modulate:a", 1.0, fade_duration)
	await logo_animator.finished
	
	await get_tree().create_timer(show_buttons_delay).timeout
	
	var buttons_animator = create_tween()
	button_list.visible = true
	buttons_animator.tween_property(button_list, "modulate:a", 1.0, fade_duration)


func _on_singleplayer_button_pressed() -> void:
	visible = false
	
	if test: return
	
	GameManager.is_hotseat = false
	GameManager.is_rematch = false
	GameManager.ruleset = General.RULESET_FINKEL
	GameEvents.play_pressed.emit()
	GameManager.start_new_game()


func _on_multiplayer_button_pressed() -> void:
	visible = false
	multiplayer_selected.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
