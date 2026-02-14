## Simple script for playing audio with an offset 
extends AudioStreamPlayer3D

@export var playback_offset: int

func _ready():
	seek(playback_offset)
	pass


func _process(_delta):
	pass
