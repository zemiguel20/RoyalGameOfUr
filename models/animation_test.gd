## This is just a very temporary script to make sure the idle animation is playing as the default animation.
## This logic will obviously move to the opponent script later.
extends AnimationPlayer

func _ready():
	play("clip_breathing")
