class_name DialogueBundle
extends DialogueEntry

## A DialogueBundle is one (part of a) sentence: 1+ audio variations, 1 subtitle string, 1 (optional) cuneiform subtitle string, 1+ animation variations.
@export var audio_variations: Array[AudioStream]
@export var caption: String
@export var caption_cuneiform: String
@export var anim_variations: Array[OpponentAnimationPlayer.Anim_Name]
@export var fixed_duration: float = -1
@export var prevents_opponent_action: bool
