class_name RulesetMenu
extends CanvasLayer


signal play_pressed(config: BoardGame.Config)
signal back_pressed

const RULESET_FINKEL = preload("res://resources/rulesets/ruleset_finkel.tres")
const RULESET_MASTERS = preload("res://resources/rulesets/ruleset_masters.tres")
const RULESET_BLITZ = preload("res://resources/rulesets/ruleset_blitz.tres")
const RULESET_TOURNAMENT = preload("res://resources/rulesets/ruleset_tournament.tres")
const RULESET_RR = preload("res://resources/rulesets/ruleset_russian_rosette.tres")

const BOARD_FINKEL = preload("res://resources/rulesets/board_layouts/layout_finkel.tres")
const BOARD_MASTERS = preload("res://resources/rulesets/board_layouts/layout_masters.tres")
const BOARD_RR = preload("res://resources/rulesets/board_layouts/layout_russian_rosette.tres")

const RULESET_LIST: Array[Ruleset] = [
	RULESET_FINKEL,
	RULESET_MASTERS,
	RULESET_BLITZ,
	RULESET_TOURNAMENT,
	RULESET_RR,
]

const BOARD_LIST: Array[BoardLayout] = [
	BOARD_FINKEL,
	BOARD_MASTERS,
	BOARD_RR,
]

var _selected_ruleset_index: int = 0
var _selected_board_index: int = 0

@onready var _switch_ruleset_left_button: TextureButton = $Control/TabletFrame/RulesetPicker/SwitchRulesetLeftButton
@onready var _ruleset_name_label: Label = $Control/TabletFrame/RulesetPicker/RulesetNameLabel
@onready var _switch_ruleset_right_button: TextureButton = $Control/TabletFrame/RulesetPicker/SwitchRulesetRightButton

@onready var _switch_board_left_button: TextureButton = $Control/TabletFrame/BoardPicker/SwitchBoardLeftButton
@onready var _board_layout_image: TextureRect = $Control/TabletFrame/BoardPicker/BoardLayoutImage
@onready var _switch_board_right_button: TextureButton = $Control/TabletFrame/BoardPicker/SwitchBoardRightButton
@onready var _board_name_label: Label = $Control/TabletFrame/BoardPicker/BoardNameLabel

@onready var _rule_1_check_box: CheckBox = $Control/TabletFrame/RulesList/Rule1CheckBox
@onready var _rule_2_check_box: CheckBox = $Control/TabletFrame/RulesList/Rule2CheckBox
@onready var _rule_3_check_box: CheckBox = $Control/TabletFrame/RulesList/Rule3CheckBox
@onready var _rule_4_check_box: CheckBox = $Control/TabletFrame/RulesList/Rule4CheckBox
@onready var _rule_5_check_box: CheckBox = $Control/TabletFrame/RulesList/Rule5CheckBox

@onready var _piece_number_slider: HSlider = $Control/TabletFrame/Sliders/PieceNumberSlider
@onready var _piece_number_label: Label = $Control/TabletFrame/Sliders/PieceNumberSlider/PieceNumberLabel
@onready var _dice_number_slider: HSlider = $Control/TabletFrame/Sliders/DiceNumberSlider
@onready var _dice_number_label: Label = $Control/TabletFrame/Sliders/DiceNumberSlider/DiceNumberLabel

@onready var _reset_button: Button = $Control/TabletFrame/ResetButton
@onready var _confirm_button: Button = $Control/TabletFrame/ConfirmButton
@onready var _back_button: Button = $Control/TabletFrame/BackButton


func _ready() -> void:
	_switch_ruleset_left_button.pressed.connect(_switch_ruleset_previous)
	_switch_ruleset_right_button.pressed.connect(_switch_ruleset_next)
	
	_switch_board_left_button.pressed.connect(_switch_board_previous)
	_switch_board_left_button.pressed.connect(_set_ruleset_name_custom)
	_switch_board_right_button.pressed.connect(_switch_board_next)
	_switch_board_right_button.pressed.connect(_set_ruleset_name_custom)
	
	_rule_1_check_box.pressed.connect(_set_ruleset_name_custom)
	_rule_2_check_box.pressed.connect(_set_ruleset_name_custom)
	_rule_3_check_box.pressed.connect(_set_ruleset_name_custom)
	_rule_4_check_box.pressed.connect(_set_ruleset_name_custom)
	_rule_5_check_box.pressed.connect(_set_ruleset_name_custom)
	
	_piece_number_slider.value_changed.connect(_update_piece_slider_label)
	_piece_number_slider.drag_started.connect(_set_ruleset_name_custom)
	_dice_number_slider.value_changed.connect(_update_dice_slider_label)
	_dice_number_slider.drag_started.connect(_set_ruleset_name_custom)
	
	_reset_button.pressed.connect(_update_ruleset_menu)
	_back_button.pressed.connect(back_pressed.emit)
	_confirm_button.pressed.connect(_start_game)
	
	_update_ruleset_menu()


func _switch_ruleset_previous() -> void:
	_selected_ruleset_index -= 1
	if _selected_ruleset_index < 0:
		_selected_ruleset_index = RULESET_LIST.size() - 1
	
	_update_ruleset_menu()


func _switch_ruleset_next() -> void:
	_selected_ruleset_index += 1
	if _selected_ruleset_index >= RULESET_LIST.size():
		_selected_ruleset_index = 0
	
	_update_ruleset_menu()


func _update_ruleset_menu() -> void:
	var ruleset = RULESET_LIST[_selected_ruleset_index].duplicate()
	_ruleset_name_label.text = ruleset.name
	
	_selected_board_index = BOARD_LIST.find(ruleset.board_layout)
	_update_board_menu()
	
	_rule_1_check_box.set_pressed_no_signal(ruleset.rosettes_are_safe)
	_rule_2_check_box.set_pressed_no_signal(ruleset.rosettes_give_extra_turn)
	_rule_3_check_box.set_pressed_no_signal(ruleset.rosettes_allow_stacking)
	_rule_4_check_box.set_pressed_no_signal(ruleset.ko_gives_extra_turn)
	_rule_5_check_box.set_pressed_no_signal(ruleset.can_move_backwards)
	
	_piece_number_slider.set_value_no_signal(ruleset.num_pieces)
	_update_piece_slider_label(ruleset.num_pieces)
	_dice_number_slider.set_value_no_signal(ruleset.num_dice)
	_update_dice_slider_label(ruleset.num_dice)


func _switch_board_previous() -> void:
	_selected_board_index -= 1
	if _selected_board_index < 0:
		_selected_board_index = BOARD_LIST.size() - 1
	
	_update_board_menu()


func _switch_board_next() -> void:
	_selected_board_index += 1
	if _selected_board_index >= BOARD_LIST.size():
		_selected_board_index = 0
	
	_update_board_menu()


func _update_board_menu() -> void:
	var layout = BOARD_LIST[_selected_board_index]
	_board_layout_image.texture = layout.preview
	_board_name_label.text = layout.name


func _update_piece_slider_label(value: float) -> void:
	_piece_number_label.text = "%d Total pieces" % _piece_number_slider.value


func _update_dice_slider_label(value: float) -> void:
	_dice_number_label.text = "%d Total dice" % _dice_number_slider.value


func _set_ruleset_name_custom() -> void:
	_ruleset_name_label.text = "Custom"


func _start_game() -> void:
	hide()
	
	var ruleset = Ruleset.new()
	ruleset.name = _ruleset_name_label.text
	ruleset.board_layout = BOARD_LIST[_selected_board_index].duplicate()
	ruleset.rosettes_are_safe = _rule_1_check_box.button_pressed
	ruleset.rosettes_give_extra_turn = _rule_2_check_box.button_pressed
	ruleset.rosettes_allow_stacking = _rule_3_check_box.button_pressed
	ruleset.ko_gives_extra_turn = _rule_4_check_box.button_pressed
	ruleset.can_move_backwards = _rule_5_check_box.button_pressed
	ruleset.num_dice = _dice_number_slider.value
	ruleset.num_pieces = _piece_number_slider.value
	
	var config := BoardGame.Config.new()
	config.ruleset = ruleset
	config.hotseat = true
	config.p2_npc = false
	
	play_pressed.emit(config)
