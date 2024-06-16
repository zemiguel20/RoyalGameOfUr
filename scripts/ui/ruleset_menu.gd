class_name RulesetMenu extends CanvasLayer


signal back_pressed
signal confirm_pressed(final_ruleset: Ruleset)

const RULESET_LIST: Array[Ruleset] = [
	General.RULESET_FINKEL,
	General.RULESET_MASTERS,
	General.RULESET_BLITZ,
	General.RULESET_TOURNAMENT,
	General.RULESET_RR,
]

const BOARD_LIST: Array[BoardLayout] = [
	General.BOARD_FINKEL,
	General.BOARD_MASTERS,
	General.BOARD_RR,
]

@export_group("References")
@export var ruleset_name_label: Label
@export var board_layout_image: TextureRect
@export var board_name_label: Label
@export var rule_1_check_box: CheckBox
@export var rule_2_check_box: CheckBox
@export var rule_3_check_box: CheckBox
@export var rule_4_check_box: CheckBox
@export var rule_5_check_box: CheckBox
@export var piece_number_slider: HSlider
@export var piece_number_label: Label
@export var dice_number_slider: HSlider
@export var dice_number_label: Label

var current_ruleset_index: int = 0
var current_board_index: int = 0
var ruleset: Ruleset


func _ready() -> void:
	_update_ruleset()


func _on_switch_ruleset_left_button_pressed() -> void:
	current_ruleset_index -= 1
	if current_ruleset_index < 0:
		current_ruleset_index = RULESET_LIST.size() - 1
	
	_update_ruleset()


func _on_switch_ruleset_right_button_pressed() -> void:
	current_ruleset_index += 1
	if current_ruleset_index >= RULESET_LIST.size():
		current_ruleset_index = 0
	
	_update_ruleset()


func _on_switch_board_left_button_pressed() -> void:
	current_board_index -= 1
	if current_board_index < 0:
		current_board_index = BOARD_LIST.size() - 1
	
	_update_board()
	ruleset.name = "Custom"
	ruleset_name_label.text = "Custom"


func _on_switch_board_right_button_pressed() -> void:
	current_board_index += 1
	if current_board_index >= BOARD_LIST.size():
		current_board_index = 0
	
	_update_board()
	ruleset.name = "Custom"
	ruleset_name_label.text = "Custom"


func _on_rule_1_check_box_toggled(toggled_on: bool) -> void:
	ruleset.rosettes_are_safe = toggled_on
	ruleset.name = "Custom"
	ruleset_name_label.text = "Custom"


func _on_rule_2_check_box_toggled(toggled_on: bool) -> void:
	ruleset.rosettes_give_extra_turn = toggled_on
	ruleset.name = "Custom"
	ruleset_name_label.text = "Custom"


func _on_rule_3_check_box_toggled(toggled_on: bool) -> void:
	ruleset.rosettes_allow_stacking = toggled_on
	ruleset.name = "Custom"
	ruleset_name_label.text = "Custom"


func _on_rule_4_check_box_toggled(toggled_on: bool) -> void:
	ruleset.captures_give_extra_turn = toggled_on
	ruleset.name = "Custom"
	ruleset_name_label.text = "Custom"


func _on_rule_5_check_box_toggled(toggled_on: bool) -> void:
	ruleset.can_move_backwards = toggled_on
	ruleset.name = "Custom"
	ruleset_name_label.text = "Custom"


func _on_piece_number_slider_value_changed(value: float) -> void:
	ruleset.num_pieces = int(value)
	piece_number_label.text = "%d Total pieces" % piece_number_slider.value
	ruleset.name = "Custom"
	ruleset_name_label.text = "Custom"


func _on_dice_number_slider_value_changed(value: float) -> void:
	ruleset.num_dice = int(value)
	dice_number_label.text = "%d Total dice" % dice_number_slider.value
	ruleset.name = "Custom"
	ruleset_name_label.text = "Custom"


func _update_ruleset() -> void:
	ruleset = RULESET_LIST[current_ruleset_index].duplicate()
	current_board_index = BOARD_LIST.find(ruleset.board_layout)
	
	ruleset_name_label.text = ruleset.name
	board_layout_image.texture = ruleset.board_layout.preview
	board_name_label.text = ruleset.board_layout.name
	
	rule_1_check_box.set_pressed_no_signal(ruleset.rosettes_are_safe)
	rule_2_check_box.set_pressed_no_signal(ruleset.rosettes_give_extra_turn)
	rule_3_check_box.set_pressed_no_signal(ruleset.rosettes_allow_stacking)
	rule_4_check_box.set_pressed_no_signal(ruleset.captures_give_extra_turn)
	rule_5_check_box.set_pressed_no_signal(ruleset.can_move_backwards)
	
	piece_number_slider.set_value_no_signal(ruleset.num_pieces)
	piece_number_label.text = "%d Total pieces" % piece_number_slider.value
	dice_number_slider.set_value_no_signal(ruleset.num_dice)
	dice_number_label.text = "%d Total dice" % dice_number_slider.value


func _update_board() -> void:
	ruleset.board_layout = BOARD_LIST[current_board_index]
	board_layout_image.texture = ruleset.board_layout.preview
	board_name_label.text = ruleset.board_layout.name


func _on_confirm_button_pressed() -> void:
	confirm_pressed.emit(ruleset.duplicate())


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_reset_button_pressed() -> void:
	_update_ruleset()
