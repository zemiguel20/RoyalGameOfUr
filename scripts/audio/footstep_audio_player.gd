extends AudioStreamPlayer3D

@export var audio_variations: Array[AudioStream]

func play_footstep():
	stream = audio_variations.pick_random()
	play()
