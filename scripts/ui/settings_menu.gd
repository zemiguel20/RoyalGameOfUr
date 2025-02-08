class_name SettingsMenu
extends CanvasLayer

# TODO: add Render resolution slider with FSR


signal back_pressed

var _resolutions: Array[VideoResolution]

@onready var _windowed_mode_check_box: HoverIconCheckBox = %WindowedModeCheckBox
@onready var _resolution_option_button: OptionButton = %ResolutionOptionButton
@onready var _master_volume_slider: HSlider = %MasterVolumeSlider
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_resolutions = Settings.get_resolutions()
	for resolution in _resolutions:
		_resolution_option_button.add_item(str(resolution))
	
	_windowed_mode_check_box.toggled.connect(_on_windowed_mode_toggled)
	_resolution_option_button.item_selected.connect(_on_resolution_selected)
	_master_volume_slider.value_changed.connect(_on_master_volume_changed)
	_back_button.pressed.connect(back_pressed.emit)
	visibility_changed.connect(_on_visibility_changed)


# NOTE: Guarantees menu is updated if settings changed elsewhere
func _on_visibility_changed() -> void:
	if not visible:
		return
	
	_windowed_mode_check_box.set_pressed_no_signal(Settings.windowed)
	_toggle_resolution_option()
	_master_volume_slider.set_value_no_signal(Settings.master_volume)


func _on_windowed_mode_toggled(toggled_on: bool) -> void:
	Settings.windowed = toggled_on
	_toggle_resolution_option()


func _toggle_resolution_option() -> void:
	_resolution_option_button.disabled = not Settings.windowed
	if Settings.windowed:
		_resolution_option_button.disabled = false
		_resolution_option_button.select(_resolutions.find(Settings.window_resolution))
	else:
		_resolution_option_button.disabled = true
		_resolution_option_button.select(_resolutions.find(Settings.get_fullscreen_resolution()))


func _on_resolution_selected(index: int) -> void:
	Settings.window_resolution = _resolutions[index]


func _on_master_volume_changed(value: float) -> void:
	Settings.master_volume = value
