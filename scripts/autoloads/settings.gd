extends Node
## Autoload with all game settings


var fast_mode: bool = false

# NOTE: this flag enables the extra features for the research purposes of this game.
var research_mode: bool = true

var windowed: bool:
	set(value):
		windowed = value
		if windowed:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

var resolution: VideoResolution:
	set(value):
		resolution = value
		get_window().size = resolution.res

var master_volume: float:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		var bus_index = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(master_volume))

var _supported_resolutions: Array[VideoResolution] = []


func _ready() -> void:
	_load_supported_resolutions()
	_load_settings_file()


func _exit_tree() -> void:
	_save_settings_file()


func get_resolutions() -> Array[VideoResolution]:
	return _supported_resolutions.duplicate()


func _load_supported_resolutions() -> void:
	var screen_index = DisplayServer.get_primary_screen()
	var screen_size = DisplayServer.screen_get_size(screen_index)
	_supported_resolutions.assign(VideoResolution.get_ordered_list().filter(
		func(res: VideoResolution):
			return res.res.x <= screen_size.x and res.res.y <= screen_size.y))
	print(_supported_resolutions)


func _save_settings_file() -> void:
	var config = ConfigFile.new()
	
	config.set_value("Graphics", "windowed", windowed)
	config.set_value("Graphics", "resolution", resolution.res)
	config.set_value("Audio", "master_volume", master_volume)
	
	config.save("user://settings.ini")


func _load_settings_file() -> void:
	var default_windowed = false
	var default_resolution = _supported_resolutions.back()
	var default_master_volume = 1.0
	
	var config = ConfigFile.new()
	var _err = config.load("user://settings.ini")
	# If the file didn't load, ignore it.
	#if err != OK:
		#return
	
	windowed = config.get_value("Graphics", "windowed", default_windowed)
	var res = config.get_value("Graphics", "resolution", default_resolution.res)
	resolution = _get_closest_supported_resolution(res)
	master_volume = config.get_value("Audio", "master_volume", default_master_volume)


func _get_closest_supported_resolution(res: Vector2i) -> VideoResolution:
	var closest_resolution = _supported_resolutions.front() as VideoResolution
	var smallest_distance = closest_resolution.res - res
	
	for i_res in _supported_resolutions:
		var distance = i_res.res - res
		if distance < smallest_distance:
			smallest_distance = distance
			closest_resolution = i_res
	
	return closest_resolution
