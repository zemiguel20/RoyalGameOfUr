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


func play_walkin():
	play_animation(Anim_Name.WALKIN, true)
	
	
func play_talking():
	play_animation(Anim_Name.THROWUPHAND, true)
	

func play_animation(anim_name: Anim_Name, return_to_idle: bool = true):
	var clip_name = _animation_names[anim_name]
	play(clip_name, 0.5)
	
	## HACK Skip 2 seconds if it is the walking animation
	if anim_name == Anim_Name.WALKIN:
		seek(2)
		await  _wait_until_animation_end(-2)
	else:
		await  _wait_until_animation_end()
		
	play_default_animation()


func cancel_animation():
	stop()
	play_default_animation()

	
func play_default_animation():
	play("clip_breathing", 0.5)


func _wait_until_animation_end(extra_delay: float = 0):
	await get_tree().create_timer(current_animation_length + extra_delay).timeout
