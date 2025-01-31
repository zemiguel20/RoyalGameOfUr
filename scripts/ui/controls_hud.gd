class_name ControlsHUD
extends CanvasLayer


var _game: BoardGame

@onready var _roll: HBoxContainer = $Controls/Roll
@onready var _shake_dice: HBoxContainer = $Controls/ShakeDice
@onready var _select_spot: HBoxContainer = $Controls/SelectSpot
@onready var _cancel_selection: HBoxContainer = $Controls/CancelSelection
@onready var _look_around: HBoxContainer = $Controls/LookAround
@onready var _fast_mode_check_box: CheckBox = $Controls/FastMode/FastModeCheckBox


func _ready():
	_fast_mode_check_box.button_pressed = Settings.fast_mode
	_fast_mode_check_box.toggled.connect(_on_fast_mode_toggled)


func init(board_game: BoardGame) -> void:
	_game = board_game
	
	_roll.hide()
	_shake_dice.hide()
	_select_spot.hide()
	_cancel_selection.hide()
	
	_look_around.visible = not _game.config.hotseat
	
	if not _game.config.p1_npc:
		var roll_controller = _game.p1_turn_controller.roll_controller as InteractiveRollController
		roll_controller.interaction_enabled.connect(_show_roll_controls)
		roll_controller.interaction_disabled.connect(_hide_roll_controls)
		
		var move_selector = _game.p1_turn_controller.move_selector as InteractiveGameMoveSelector
		move_selector.selection_enabled.connect(_show_selection_controls)
		move_selector.selection_disabled.connect(_hide_selection_controls)
	
	if not _game.config.p2_npc:
		var roll_controller = _game.p2_turn_controller.roll_controller as InteractiveRollController
		roll_controller.interaction_enabled.connect(_show_roll_controls)
		roll_controller.interaction_disabled.connect(_hide_roll_controls)
		
		var move_selector = _game.p2_turn_controller.move_selector as InteractiveGameMoveSelector
		move_selector.selection_enabled.connect(_show_selection_controls)
		move_selector.selection_disabled.connect(_hide_selection_controls)


func _show_roll_controls() -> void:
	_roll.show()
	_shake_dice.show()


func _hide_roll_controls() -> void:
	_roll.hide()
	_shake_dice.hide()


func _show_selection_controls() -> void:
	_select_spot.show()
	_cancel_selection.show()


func _hide_selection_controls() -> void:
	_select_spot.hide()
	_cancel_selection.hide()


func _on_fast_mode_toggled(toggled_on: bool) -> void:
	Settings.fast_mode = toggled_on
