extends CanvasLayer


@export var _fading_duration = 2.5
@onready var play: Button = $"Main Menu/Play"
@onready var quit: Button = $"Main Menu/Quit"
@onready var fade_panel: ColorRect = $Fade_Panel
@onready var main_menu: Control = $"Main Menu"
@onready var endscreen: Control = $EndScreen as Endscreen


func _ready() -> void:
	play.pressed.connect(_on_play_pressed)
	quit.pressed.connect(_on_quit_pressed)
	GameEvents.game_ended.connect(_on_game_ended)
	GameEvents.rematch_triggered.connect(_on_play_pressed)


func _on_game_ended(_player):
	visible = true
	endscreen.display(_player)
	

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


func _on_quit_pressed():
	get_tree().quit()
