extends CanvasLayer


var ruleset_list: Array[Ruleset] = [
	General.RULESET_FINKEL,
	General.RULESET_MASTERS,
	General.RULESET_BLITZ,
	General.RULESET_TOURNAMENT,
	General.RULESET_RR,
]

var board_list: Array[BoardLayout] = [
	General.BOARD_FINKEL,
	General.BOARD_MASTERS,
	General.BOARD_RR,
]

var current_ruleset_index: int = 0
var current_board_index: int = 0


@onready var main_menu: Control = $MainMenu
@onready var ruleset_menu: Control = $RulesetMenu

@onready var ruleset_name_label: Label = $RulesetMenu/TabletFrame/RulesetPicker/RulesetNameLabel
@onready var board_layout_image: TextureRect = $RulesetMenu/TabletFrame/BoardPicker/BoardLayoutImage
@onready var board_name_label: Label = $RulesetMenu/TabletFrame/BoardPicker/BoardNameLabel
@onready var rule_1_check_box: CheckBox = $RulesetMenu/TabletFrame/RulesList/Rule1CheckBox
@onready var rule_2_check_box: CheckBox = $RulesetMenu/TabletFrame/RulesList/Rule2CheckBox
@onready var rule_3_check_box: CheckBox = $RulesetMenu/TabletFrame/RulesList/Rule3CheckBox
@onready var rule_4_check_box: CheckBox = $RulesetMenu/TabletFrame/RulesList/Rule4CheckBox
@onready var rule_5_check_box: CheckBox = $RulesetMenu/TabletFrame/RulesList/Rule5CheckBox
@onready var piece_number_slider: HSlider = $RulesetMenu/TabletFrame/VBoxContainer/HBoxContainer/PieceNumberSlider
@onready var piece_number_label: Label = $RulesetMenu/TabletFrame/VBoxContainer/HBoxContainer/PieceNumberLabel
@onready var dice_number_slider: HSlider = $RulesetMenu/TabletFrame/VBoxContainer/HBoxContainer2/DiceNumberSlider
@onready var dice_number_label: Label = $RulesetMenu/TabletFrame/VBoxContainer/HBoxContainer2/DiceNumberLabel


@export var _fading_duration = 2.5


@onready var fade_panel: ColorRect = $Fade_Panel


func _ready() -> void:
	main_menu.visible = true
	ruleset_menu.visible = false


func _on_singleplayer_button_pressed() -> void:
	visible = false
	Settings.is_hotseat_mode = false
	Settings.ruleset = General.RULESET_FINKEL
	GameEvents.play_pressed.emit()


func _on_multiplayer_button_pressed() -> void:
	main_menu.visible = false
	ruleset_menu.visible = true
	current_ruleset_index = 0
	
	_update_ruleset()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_switch_ruleset_left_button_pressed() -> void:
	current_ruleset_index -= 1
	if current_ruleset_index < 0:
		current_ruleset_index = ruleset_list.size() - 1
	
	_update_ruleset()


func _on_switch_ruleset_right_button_pressed() -> void:
	current_ruleset_index += 1
	if current_ruleset_index >= ruleset_list.size():
		current_ruleset_index = 0
	
	_update_ruleset()


func _on_switch_board_left_button_pressed() -> void:
	current_board_index -= 1
	if current_board_index < 0:
		current_board_index = board_list.size() - 1
	
	_update_board()
	ruleset_name_label.text = "Custom"


func _on_switch_board_right_button_pressed() -> void:
	current_board_index += 1
	if current_board_index >= board_list.size():
		current_board_index = 0
	
	_update_board()
	ruleset_name_label.text = "Custom"


func _on_rule_1_check_box_toggled(toggled_on: bool) -> void:
	Settings.ruleset.rosettes_are_safe = toggled_on
	ruleset_name_label.text = "Custom"


func _on_rule_2_check_box_toggled(toggled_on: bool) -> void:
	Settings.ruleset.rosettes_give_extra_turn = toggled_on
	ruleset_name_label.text = "Custom"


func _on_rule_3_check_box_toggled(toggled_on: bool) -> void:
	Settings.ruleset.rosettes_allow_stacking = toggled_on
	ruleset_name_label.text = "Custom"


func _on_rule_4_check_box_toggled(toggled_on: bool) -> void:
	Settings.ruleset.captures_give_extra_turn = toggled_on
	ruleset_name_label.text = "Custom"


func _on_rule_5_check_box_toggled(toggled_on: bool) -> void:
	Settings.ruleset.can_move_backwards = toggled_on
	ruleset_name_label.text = "Custom"


func _on_piece_number_slider_value_changed(value: float) -> void:
	Settings.ruleset.num_pieces = value
	piece_number_label.text = "%d Total pieces" % piece_number_slider.value
	ruleset_name_label.text = "Custom"


func _on_dice_number_slider_value_changed(value: float) -> void:
	Settings.ruleset.num_dice = value
	dice_number_label.text = "%d Total dice" % dice_number_slider.value
	ruleset_name_label.text = "Custom"


func _update_ruleset() -> void:
	Settings.ruleset = ruleset_list[current_ruleset_index].duplicate()
	current_board_index = board_list.find(Settings.ruleset.board_layout)
	
	ruleset_name_label.text = Settings.ruleset.name
	board_layout_image.texture = Settings.ruleset.board_layout.preview
	board_name_label.text = Settings.ruleset.board_layout.name
	
	rule_1_check_box.set_pressed_no_signal(Settings.ruleset.rosettes_are_safe)
	rule_2_check_box.set_pressed_no_signal(Settings.ruleset.rosettes_give_extra_turn)
	rule_3_check_box.set_pressed_no_signal(Settings.ruleset.rosettes_allow_stacking)
	rule_4_check_box.set_pressed_no_signal(Settings.ruleset.captures_give_extra_turn)
	rule_5_check_box.set_pressed_no_signal(Settings.ruleset.can_move_backwards)
	
	piece_number_slider.set_value_no_signal(Settings.ruleset.num_pieces)
	piece_number_label.text = "%d Total pieces" % piece_number_slider.value
	dice_number_slider.set_value_no_signal(Settings.ruleset.num_dice)
	dice_number_label.text = "%d Total dice" % dice_number_slider.value


func _update_board() -> void:
	Settings.ruleset.board_layout = board_list[current_board_index]
	board_layout_image.texture = Settings.ruleset.board_layout.preview
	board_name_label.text = Settings.ruleset.board_layout.name


func _on_confirm_button_pressed() -> void:
	visible = false
	Settings.is_hotseat_mode = true
	GameEvents.play_pressed.emit()


func _on_back_button_pressed() -> void:
	ruleset_menu.visible = false
	main_menu.visible = true
