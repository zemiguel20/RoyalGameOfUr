extends CanvasLayer


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

@export var skip_intro := false
@export var fade_duration := 0.5
@export var pause_duration := 1.0

@onready var splash_screen: Control = $SplashScreen
@onready var entities_logos: Control = $SplashScreen/EntitiesLogos
@onready var godot_logo: TextureRect = $SplashScreen/GodotLogo

@onready var title_screen: Control = $TitleScreen
@onready var game_title_logo: TextureRect = $TitleScreen/GameTitleLogo
@onready var press_to_start_label: Label = $TitleScreen/PressToStartLabel

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

var current_ruleset_index: int = 0
var current_board_index: int = 0


func _ready() -> void:
	GameEvents.back_to_main_menu_pressed.connect(_on_back_to_main_menu)
	
	splash_screen.visible = false
	title_screen.visible = false
	main_menu.visible = false
	ruleset_menu.visible = false
	
	if skip_intro:
		_show_main_menu()
	else:
		_play_splash_screen_sequence()


func _play_splash_screen_sequence() -> void:
	splash_screen.visible = true
	splash_screen.modulate.a = 1.0
	godot_logo.modulate.a = 0.0
	entities_logos.modulate.a = 0.0
	
	# Idle time to load
	await get_tree().create_timer(0.5).timeout
	
	var animator: Tween
	
	# Fade in team and school logos
	animator = create_tween()
	animator.tween_property(entities_logos, "modulate:a", 1.0, fade_duration)
	await animator.finished
	
	await _skippable_pause(pause_duration)
	
	# Fade out entities and fade in Godot logo
	animator = create_tween()
	animator.tween_property(entities_logos, "modulate:a", 0.0, fade_duration)
	animator.tween_property(godot_logo, "modulate:a", 1.0, fade_duration)
	await animator.finished
	
	await _skippable_pause(pause_duration)
	
	# Fade out Godot logo and then background
	animator = create_tween()
	animator.tween_property(godot_logo, "modulate:a", 0.0, fade_duration)
	animator.tween_property(splash_screen, "modulate:a", 0.0, fade_duration)
	await animator.finished
	splash_screen.visible = false
	
	_show_title_screen()


func _show_title_screen() -> void:
	title_screen.visible = true
	game_title_logo.modulate.a = 0.0
	press_to_start_label.modulate.a = 0.0
	
	var animator = create_tween()
	animator.tween_property(game_title_logo, "modulate:a", 1.0, fade_duration)
	await animator.finished
	
	# Bit of idle time just to EXPOSE THE LOGO AND ITS GREATNESS AHAHAHAHAHAHA
	await get_tree().create_timer(0.5).timeout
	
	press_to_start_label.modulate.a = 1.0
	
	await _skippable_pause()
	
	title_screen.visible = false
	_show_main_menu()


func _skippable_pause(duration := 0.0) -> void:
	if duration > 0.0:
		var timer = get_tree().create_timer(duration)
		while timer.time_left > 0 and not Input.is_action_pressed("skip_splash_screen"):
			await Engine.get_main_loop().process_frame
	else:
		while not Input.is_action_pressed("skip_splash_screen"):
			await Engine.get_main_loop().process_frame


func _on_back_to_main_menu() -> void:
	_show_main_menu()


func _show_main_menu() -> void:
	visible = true
	main_menu.visible = true


func _on_singleplayer_button_pressed() -> void:
	visible = false
	GameManager.is_hotseat = false
	GameManager.is_rematch = false
	GameManager.ruleset = General.RULESET_FINKEL
	GameManager.start_new_game()
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
	ruleset_name_label.text = "Custom"


func _on_switch_board_right_button_pressed() -> void:
	current_board_index += 1
	if current_board_index >= BOARD_LIST.size():
		current_board_index = 0
	
	_update_board()
	ruleset_name_label.text = "Custom"


func _on_rule_1_check_box_toggled(toggled_on: bool) -> void:
	GameManager.ruleset.rosettes_are_safe = toggled_on
	ruleset_name_label.text = "Custom"


func _on_rule_2_check_box_toggled(toggled_on: bool) -> void:
	GameManager.ruleset.rosettes_give_extra_turn = toggled_on
	ruleset_name_label.text = "Custom"


func _on_rule_3_check_box_toggled(toggled_on: bool) -> void:
	GameManager.ruleset.rosettes_allow_stacking = toggled_on
	ruleset_name_label.text = "Custom"


func _on_rule_4_check_box_toggled(toggled_on: bool) -> void:
	GameManager.ruleset.captures_give_extra_turn = toggled_on
	ruleset_name_label.text = "Custom"


func _on_rule_5_check_box_toggled(toggled_on: bool) -> void:
	GameManager.ruleset.can_move_backwards = toggled_on
	ruleset_name_label.text = "Custom"


func _on_piece_number_slider_value_changed(value: float) -> void:
	GameManager.ruleset.num_pieces = int(value)
	piece_number_label.text = "%d Total pieces" % piece_number_slider.value
	ruleset_name_label.text = "Custom"


func _on_dice_number_slider_value_changed(value: float) -> void:
	GameManager.ruleset.num_dice = int(value)
	dice_number_label.text = "%d Total dice" % dice_number_slider.value
	ruleset_name_label.text = "Custom"


func _update_ruleset() -> void:
	GameManager.ruleset = RULESET_LIST[current_ruleset_index].duplicate()
	current_board_index = BOARD_LIST.find(GameManager.ruleset.board_layout)
	
	ruleset_name_label.text = GameManager.ruleset.name
	board_layout_image.texture = GameManager.ruleset.board_layout.preview
	board_name_label.text = GameManager.ruleset.board_layout.name
	
	rule_1_check_box.set_pressed_no_signal(GameManager.ruleset.rosettes_are_safe)
	rule_2_check_box.set_pressed_no_signal(GameManager.ruleset.rosettes_give_extra_turn)
	rule_3_check_box.set_pressed_no_signal(GameManager.ruleset.rosettes_allow_stacking)
	rule_4_check_box.set_pressed_no_signal(GameManager.ruleset.captures_give_extra_turn)
	rule_5_check_box.set_pressed_no_signal(GameManager.ruleset.can_move_backwards)
	
	piece_number_slider.set_value_no_signal(GameManager.ruleset.num_pieces)
	piece_number_label.text = "%d Total pieces" % piece_number_slider.value
	dice_number_slider.set_value_no_signal(GameManager.ruleset.num_dice)
	dice_number_label.text = "%d Total dice" % dice_number_slider.value


func _update_board() -> void:
	GameManager.ruleset.board_layout = BOARD_LIST[current_board_index]
	board_layout_image.texture = GameManager.ruleset.board_layout.preview
	board_name_label.text = GameManager.ruleset.board_layout.name


func _on_confirm_button_pressed() -> void:
	visible = false
	GameManager.is_hotseat = true
	GameManager.is_rematch = false
	GameManager.start_new_game()
	GameEvents.play_pressed.emit()


func _on_back_button_pressed() -> void:
	ruleset_menu.visible = false
	main_menu.visible = true
