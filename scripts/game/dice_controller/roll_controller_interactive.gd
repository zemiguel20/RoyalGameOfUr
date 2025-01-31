class_name InteractiveRollController
extends RollController
## Dice can be interacted with a mouse. Click to toss immediately, or hold press to shake dice.


signal interaction_enabled
signal interaction_disabled


func _start_toss_procedure() -> void:
	_enable_dice_interaction()


func _enable_dice_interaction() -> void:
	for die in _dice:
		die.set_input_reading(true)
		
		die.clicked.connect(_toss_dice)
		die.clicked.connect(_deactivate_dice_interaction)
		die.hold_started.connect(_start_shaking)
		die.hold_stopped.connect(_stop_shaking)
		die.hold_stopped.connect(_deactivate_dice_interaction)
		die.mouse_entered.connect(_highlight_hovered)
		die.mouse_exited.connect(_highlight_selectable)
	
	_highlight_selectable()
	interaction_enabled.emit()


func _highlight_selectable() -> void:
	for die in _dice:
		die.enable_highlight(General.get_highlight_color(General.HighlightType.SELECTABLE))


func _highlight_hovered() -> void:
	for die in _dice:
		die.enable_highlight(General.get_highlight_color(General.HighlightType.HOVERED))


func _deactivate_dice_interaction() -> void:
	for die in _dice:
		die.set_input_reading(false)
		
		die.clicked.disconnect(_toss_dice)
		die.clicked.disconnect(_deactivate_dice_interaction)
		die.hold_started.disconnect(_start_shaking)
		die.hold_stopped.disconnect(_stop_shaking)
		die.hold_stopped.disconnect(_deactivate_dice_interaction)
		die.mouse_entered.disconnect(_highlight_hovered)
		die.mouse_exited.disconnect(_highlight_selectable)
		
		die.disable_highlight()
		interaction_disabled.emit()
