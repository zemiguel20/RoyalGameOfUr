## A DialogueGroup is a group of DialogueSingleEntries that are meant to be played after each other.
class_name DialogueSequence
extends Resource

@export var dialogue_entries: Array[DialogueSingleEntry]
@export_range(0, 10) var weight: int = 5
