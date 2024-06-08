class_name OpponentAnimationPlayer
extends AnimationPlayer

enum Anim_Name {
	BREATHING = 0,
	CLASPSHANDS = 1,
	CROSSARMS = 2,
	LEANBACK = 3,
	LOOKAROUND = 4,
	NOD = 5,
	SCRATCHBEARD = 6,
	THROWUPHAND = 7,
	WALKIN = 8
}

var _animation_names = [
	"clip_breathing",
	"clip_claspHands",
	"clip_crossArms",
	"clip_leanBack",
	"clip_lookAround",
	"clip_nod",
	"clip_scratchBeard",
	"clip_throwUpHand",
	"clip_walkIn"
]



var thinking_animations: Array
var knockout_reaction_probability: float = 0.5
var knockout_animations: Array
var idle_animations: Array


func _process(delta):
	if not is_playing():
		play_default_animation()	
	
	
func play_animation(anim_name: Anim_Name, return_to_idle: bool = true, custom_blend = 0.5):
	var clip_name = _animation_names[anim_name]
	if clip_name == current_animation:
		return
		
	play(clip_name, custom_blend)
	await  _wait_until_animation_end()


func cancel_animation():
	stop()
	play_default_animation()

	
func play_default_animation():
	if current_animation != "clip_breathing":
		play("clip_breathing")
		
		
func play_walkin():
	play_animation(Anim_Name.WALKIN, true, 0.0)
	seek(1.7)
	await _wait_until_animation_end(-2)


func _wait_until_animation_end(extra_delay: float = 0):
	if get_tree():
		await get_tree().create_timer(current_animation_length + extra_delay).timeout
