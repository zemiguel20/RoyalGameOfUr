class_name DialogueGroup
extends Resource

## NOTE: Since we only use a category once, keeping it as a string might actually make more sense.
@export var category: DialogueSystem.Category
@export var play_in_order: bool
@export var dialogue_sequences: Array[DialogueSequence]
@export_range(1, 10) var weight_for_empty: int
