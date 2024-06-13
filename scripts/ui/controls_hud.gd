extends CanvasLayer


@onready var interact: HBoxContainer = $Controls/Interact
@onready var look_around: HBoxContainer = $Controls/LookAround
@onready var cancel: HBoxContainer = $Controls/Cancel
@onready var fast_move: HBoxContainer = $Controls/FastMove
@onready var fast_move_check_box: CheckBox = $Controls/FastMove/FastMoveCheckBox


func _ready():
	visible = false
	fast_move.visible = false
	
	GameEvents.game_started.connect(_on_game_started)
	GameEvents.game_ended.connect(_on_game_ended)
	GameEvents.drag_move_start.connect(_on_drag_move_started)
	GameEvents.drag_move_stopped.connect(_on_drag_move_stopped)
	GameEvents.new_turn_started.connect(_on_new_turn_started)
	
	fast_move_check_box.toggled.connect(_on_fast_move_toggled)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_1 and event.pressed:
			fast_move.visible = true
			fast_move_check_box.button_pressed = not fast_move_check_box.button_pressed


func _on_game_started() -> void:
	visible = true
	_show_controls_regular()


func _on_game_ended() -> void:
	visible = false


func _on_drag_move_started() -> void:
	_show_controls_in_move()


func _on_drag_move_stopped() -> void:
	_show_controls_regular()


func _on_new_turn_started() -> void:
	# In singleplayer, show fast mode option after some turns
	if not Settings.is_hotseat_mode and GameState.turn_number >= 4:
		fast_move.visible = true
		fast_move_check_box.button_pressed = not fast_move_check_box.button_pressed


func _show_controls_regular() -> void:
	interact.visible = true
	cancel.visible = false
	look_around.visible = not Settings.is_hotseat_mode


func _show_controls_in_move():
	interact.visible = false
	cancel.visible = true


func _on_fast_move_toggled(toggled_on: bool) -> void:
	Settings.fast_move_enabled = toggled_on
	print(Settings.fast_move_enabled)
