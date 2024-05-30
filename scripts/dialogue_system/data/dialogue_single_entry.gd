class_name DialogueSingleEntry
extends Resource

## A DialogueSingleEntry is one (part of a) sentence: 1 audioclip and 1 subtitle string, multiple animations to choose from.
@export var audio: AudioStream
@export var caption: String
@export var caption_cuneiform: String
@export var anim_variations: Array[OpponentAnimationPlayer.Anim_Name]
@export var fixed_duration: float = -1
@export var prevents_opponent_action: bool

## TODO: I could add some simple has_ functions, like has_animations
