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
	# TODO: load and save settings from and to file
	
	var screen_index = DisplayServer.get_primary_screen()
	var screen_size = DisplayServer.screen_get_size(screen_index)
	
	_supported_resolutions.assign(VideoResolution.get_ordered_list().filter(
		func(res: VideoResolution):
			return res.res.x <= screen_size.x and res.res.y <= screen_size.y))
	print(_supported_resolutions)
	
	windowed = false
	resolution = _supported_resolutions.back()
	master_volume = 1.0


func get_resolutions() -> Array[VideoResolution]:
	return _supported_resolutions.duplicate()
