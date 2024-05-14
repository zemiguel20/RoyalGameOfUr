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
	THROWUPHANDS = 7,
	WALKIN = 8
}

var _animation_names = [
	"clip_breathing",
	"clip_claspshands",
	"clip_crossarms",
	"clip_leanback",
	"clip_lookaround",
	"clip_nod",
	"clip_scratchbeard",
	"clip_throwuphands",
	"clip_walkin"
]

var thinking_animations: Array
var knockout_reaction_probability: float = 0.5
var knockout_animations: Array
var idle_animations: Array


func play_walkin():
	play("clip_walkIn")
	await  _wait_until_animation_end()
	#play_default_animation()	
	
	
func play_talking():
	play("clip_throwUpHand")
	await  _wait_until_animation_end()
	#play_default_animation()	
	
	
## Has a chance to select a thinking animation.
func play_thinking():
	## Could add something to make sure we dont pick the same when too often
	play(thinking_animations.pick_random())
	await  _wait_until_animation_end()
	#play_default_animation()
	
	

func _play_animation(anim_name: Anim_Name, return_to_idle: bool):
	var clip_name = _animation_names[anim_name]
	play(clip_name)
	await  _wait_until_animation_end()
	play_default_animation()

	
func play_default_animation():
	play("clip_breathing")


func _wait_until_animation_end():
	await get_tree().create_timer(current_animation_length).timeout
