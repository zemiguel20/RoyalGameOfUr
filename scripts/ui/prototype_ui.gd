extends CanvasLayer


@onready var main_menu: Control = $MainMenu
@onready var ruleset_menu: Control = $RulesetMenu

@onready var ruleset_name_label: Label = $RulesetMenu/TabletFrame/RulesetPicker/RulesetNameLabel


@export var _fading_duration = 2.5


@onready var fade_panel: ColorRect = $Fade_Panel


# When someone wins the game, we will fadeout and then reload the scene.
func _fadeout():
	visible = true
	var tween = create_tween().tween_property(fade_panel, "color:a", 1.0, _fading_duration)
	await tween.finished
	get_tree().reload_current_scene()


func _on_play_pressed():
	visible = false
	main_menu.visible = false
	GameEvents.play_pressed.emit()


func _on_singleplayer_button_pressed() -> void:
	visible = false
	Settings.is_hotseat_mode = false
	Settings.ruleset = General.RULESET_FINKEL
	GameEvents.play_pressed.emit()


func _on_multiplayer_button_pressed() -> void:
	main_menu.visible = false
	ruleset_menu.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_switch_ruleset_left_button_pressed() -> void:
	pass # Replace with function body.


func _on_switch_ruleset_right_button_pressed() -> void:
	pass # Replace with function body.
