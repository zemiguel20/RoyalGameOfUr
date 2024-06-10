extends CanvasLayer


@onready var play: Button = $"Main Menu/Play"
@onready var quit: Button = $"Main Menu/Quit"
@onready var main_menu: Control = $"Main Menu"
@onready var endscreen: Control = $EndScreen as Endscreen


func _ready() -> void:
	GameEvents.game_ended.connect(_on_game_ended)
	if GameState.is_rematch:
		_hide_menu()
	else:
		play.pressed.connect(_on_play_pressed)
		quit.pressed.connect(_on_quit_pressed)


func _on_game_ended(winner):
	visible = true
	endscreen.display(winner)
	
	
func _hide_menu():
	visible = false
	main_menu.visible = false


func _on_play_pressed():
	visible = false
	main_menu.visible = false
	GameEvents.play_pressed.emit()


func _on_quit_pressed():
	get_tree().quit()
