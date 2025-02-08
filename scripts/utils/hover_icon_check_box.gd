class_name HoverIconCheckBox
extends CheckBox
## A checkbox that also contains a hover texture for both normal and pressed states.
## Useful when check boxes don't have text description.


## The check icon to display when the CheckBox is checked and hovered.
@export var hover_checked: Texture2D
## The check icon to display when the CheckBox is unchecked and hovered.
@export var hover_unchecked: Texture2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_hovered)
	mouse_exited.connect(_on_dehovered)


func _on_hovered() -> void:
	add_theme_icon_override("checked", hover_checked)
	add_theme_icon_override("unchecked", hover_unchecked)


func _on_dehovered() -> void:
	remove_theme_icon_override("checked")
	remove_theme_icon_override("unchecked")
