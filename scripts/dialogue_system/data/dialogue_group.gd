class_name DialogueGroup
extends Resource

## NOTE: Since we only use a category once, keeping it as a string might actually make more sense.
@export var category: DialogueSystem.Category
## Whether this group should play in a set order, or randomly
@export var play_in_order: bool
## If true, this group will interrupt a group that is currently playing if it does not have priority
@export var has_priority: bool

@export_range(0, 3, 0.1) var initial_delay: float = 0.5

@export var dialogue_sequences: Array[DialogueSequence]
@export var weight_for_empty: int
