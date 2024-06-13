## This task is used for letting NPCs make background sounds.
## It is NOT used for dialogue, since this should be handled by the DialogueSystem
class_name PlayAudioTask
extends BTNode

var _clip: AudioStream
var _wait_until_clip_end: bool
var _status

func _init(clip: AudioStream, wait_until_clip_end: bool):
	_clip = clip
	_wait_until_clip_end = wait_until_clip_end
	
	
func on_start():
	var audio_player = _blackboard.read("Audio Player") as AudioStreamPlayer
	
	audio_player.stream = _clip
	audio_player.play()
	if _wait_until_clip_end:
		_status = Status.Running
		await audio_player.get_tree().create_timer(_clip.get_length())
	
	_status = Status.Succeeded
	
	
func on_process(delta):
	return _status

