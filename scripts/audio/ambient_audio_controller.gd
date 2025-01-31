class_name AmbientAudioController
extends Node


const FADE_DURATION: float = 1.0 # seconds


func _ready() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), -80)
	fade_in_audio()


func fade_in_audio() -> void:
	await _fade_audio(0.0)


func fade_out_audio() -> void:
	await _fade_audio(-80)


# Decrease audio NOTE: Not compatible with tweeners
func _fade_audio(target_volume: float) -> void:
	var time = 0.0
	var current_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Ambient"))
	while time < FADE_DURATION:
		var new_volume = lerpf(current_volume, target_volume, time / FADE_DURATION)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), new_volume)
		await Engine.get_main_loop().process_frame
		time += get_process_delta_time()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), target_volume)
