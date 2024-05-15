class_name DialogueSingleEntry
extends Resource

## A DialogueSingleEntry is one (part of a) sentence: 1 audioclip and 1 subtitle string, multiple animations to choose from.
@export var audio: AudioStream
@export var caption: String
@export var anim_variations: Array[OpponentAnimationPlayer.Anim_Name]

## TODO: I could add some simple has_ functions, like has_animations
