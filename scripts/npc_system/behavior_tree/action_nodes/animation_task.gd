class_name PlayAnimationTask
extends BTNode

var _anim_name: String
var _wait_until_anim_end: bool
var _custom_blend: float
var _init_delay: float
var _status


func _init(anim_name: String, wait_until_anim_end: bool = false, custom_blend: float = 0.2, init_delay: float = 0):
	_anim_name = anim_name
	_wait_until_anim_end = wait_until_anim_end
	_custom_blend = custom_blend
	_init_delay = init_delay


func on_start():
	var animation_player = _blackboard.read("Animation Player") as AnimationPlayer
	if not animation_player.has_animation(_anim_name):
		return Status.Failed
	
	await animation_player.get_tree().create_timer(_init_delay).timeout
	animation_player.play(_anim_name, _custom_blend)
	if _wait_until_anim_end:
		_status = Status.Running
		var duration = animation_player.current_animation_length
		await animation_player.get_tree().create_timer(duration - 0.05).timeout
	
	_status = Status.Succeeded


func on_process(delta):
	return _status
