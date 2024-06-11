extends CanvasLayer


@onready var controls_regular = $ControlsRegular as BoxContainer
@onready var controls_in_move = $ControlsInMove as BoxContainer

@onready var fast_move_rect = $ControlsRegular/OneKey as TextureRect
@onready var fast_move_label = $ControlsRegular/OneKey/PieceMode as Label

var regular_controls_shown: bool


func _ready():
	GameEvents.game_started.connect(_show_controls_regular)
	GameEvents.move_phase_started.connect(_show_fast_mode_label)
	GameEvents.fast_move_toggled.connect(_toggle_fast_move_label)


func _show_controls_regular():
	regular_controls_shown = true
	
	controls_regular.visible = true
	controls_in_move.visible = false


func _show_controls_in_move():
	regular_controls_shown = false
	
	controls_regular.visible = true
	controls_in_move.visible = false


func _show_fast_mode_label(player: General.Player, x: int):
	if player == General.Player.ONE and GameState.player_turns_made == 3:
		fast_move_rect.visible = true


func _toggle_fast_move_label(enabled: bool):
	fast_move_label.text = "🗹 Fast movement" if enabled else "☐ Fast movement"
	
	if regular_controls_shown:
		fast_move_rect.visible = true
