extends CanvasLayer

@export var _board_layout_images: Array[BoardLayoutStruct]
@export var _fading_duration = 2.5

@onready var _main_menu = $"Main Menu" as Control
@onready var _rules_menu = $"Settings Menu" as Control
@onready var _fade_panel = $_fade_panel as ColorRect
@onready var _ruleset_label = $"Settings Menu/MarginContainer/VBoxContainer/RulesetSelection/HBoxContainer/Ruleset Label" as Label
@onready var _image_board_layout = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/LayoutSelection/HBoxContainer/BoardLayout Image" as TextureRect
@onready var _checkbox_rosettes_extra_turn = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/RosetteExtraTurn" as Button
@onready var _checkbox_rosettes_safe = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/RosetteSafe" as Button
@onready var _checkbox_rosettes_stacking = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/RosetteStacking" as Button
@onready var _checkbox_captures_extra_move = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/CaptureExtraTurn" as Button
@onready var _checkbox_pieces_backwards = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/PiecesBackwards" as Button
@onready var _slider_piece_amount = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/PieceAmount/HSlider" as Slider
@onready var _slider_dice_amount = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/DiceAmount/HSlider" as Slider
@onready var _label_piece_amount = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/PieceAmount/Label" as Label
@onready var _label_dice_amount = $"Settings Menu/MarginContainer/VBoxContainer/Rules/ScrollContainer/VBoxContainer/DiceAmount/Label" as Label

@onready var play: Button = $"Main Menu/Play"
@onready var quit: Button = $"Main Menu/Quit"

var _delta: float

func _ready() -> void:
	play.pressed.connect(_on_play_pressed)
	quit.pressed.connect(_on_quit_pressed)


func _process(delta):
	_delta = delta


func _fadeout():
	visible = true
	var tween = create_tween().tween_property(_fade_panel, "color:a", 1.0, _fading_duration)
	await tween.finished
	get_tree().reload_current_scene()


func _on_play_pressed():
	visible = false
	_main_menu.visible = false
	GameEvents.play_pressed.emit()


func _on_rules_pressed():
	_main_menu.visible = false
	_rules_menu.visible = true


func _on_rules_confirmed():
	_main_menu.visible = true
	_rules_menu.visible = false


func _on_rosettes_extra_move_toggle(enable: bool):
	Settings.rosettes_grant_extra_turn = enable
	_handle_custom_ruleset_label()


func _on_rosettes_safe_toggle(enable: bool):
	Settings.rosettes_are_safe = enable
	_handle_custom_ruleset_label()


func _on_rosettes_stacking_toggle(enable: bool):
	Settings.rosettes_allow_stacking = enable
	_handle_custom_ruleset_label()


func _on_captures_extra_move_toggle(enable: bool):
	Settings.captures_grant_extra_turn = enable
	_handle_custom_ruleset_label()


func _on_pieces_backwards_toggle(enable: bool):
	Settings.pieces_can_move_backwards = enable
	_handle_custom_ruleset_label()


func _on_piece_amount_changed(amount: float):
	Settings.num_pieces = amount as int
	_label_piece_amount.text = "Pieces: " + str(Settings.num_pieces)
	_handle_custom_ruleset_label()
	

func _on_dice_amount_changed(amount: float):
	Settings.num_dice = amount as int
	_label_dice_amount.text = "Dice: " + str(Settings.num_dice)
	_handle_custom_ruleset_label()


func _handle_custom_ruleset_label():
	_ruleset_label.text = "Custom"
	if Settings.try_get_identified_ruleset():
		_update_ruleset_label()


func _on_previous_ruleset_selected():
	Settings.on_previous_ruleset()
	_update_ui_on_ruleset_change()


func _on_next_ruleset_selected():
	Settings.on_next_ruleset()
	_update_ui_on_ruleset_change()


func _on_previous_board_layout_selected():
	Settings.on_previous_board_layout()
	_image_board_layout.texture = _board_layout_images[Settings.board_layout].layout_image
	_handle_custom_ruleset_label()


func _on_next_board_layout_selected():
	Settings.on_next_board_layout()
	_image_board_layout.texture = _board_layout_images[Settings.board_layout].layout_image
	_handle_custom_ruleset_label()


func _update_ui_on_ruleset_change():
	_update_ruleset_label()	
	_image_board_layout.texture = _board_layout_images[Settings.board_layout].layout_image
	_checkbox_rosettes_extra_turn.set_pressed_no_signal(Settings.rosettes_grant_extra_turn)
	_checkbox_rosettes_safe.set_pressed_no_signal(Settings.rosettes_are_safe)
	_checkbox_rosettes_stacking.set_pressed_no_signal(Settings.rosettes_allow_stacking)
	_checkbox_captures_extra_move.set_pressed_no_signal(Settings.captures_grant_extra_turn)
	_checkbox_pieces_backwards.set_pressed_no_signal(Settings.pieces_can_move_backwards)
	_slider_piece_amount.set_value_no_signal(Settings.num_pieces)
	_slider_dice_amount.set_value_no_signal(Settings.num_dice)
	_label_piece_amount.text = "Pieces: " + str(Settings.num_pieces)
	_label_dice_amount.text = "Dice: " + str(Settings.num_dice)


func _update_ruleset_label():
	var text = Settings.Ruleset.keys()[Settings.selected_ruleset] as String
	_ruleset_label.text = text.to_pascal_case()
	_main_menu.visible = false
	GameEvents.play_pressed.emit()


func _on_quit_pressed():
	get_tree().quit()
