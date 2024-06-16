class_name StartMenu extends CanvasLayer


signal singleplayer_selected
signal multiplayer_selected

@export_group("References")
@export var game_version_label: Label


func _ready() -> void:
	game_version_label.text = ProjectSettings.get_setting("application/config/version")


func _on_singleplayer_button_pressed() -> void:
	singleplayer_selected.emit()


func _on_multiplayer_button_pressed() -> void:
	multiplayer_selected.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
