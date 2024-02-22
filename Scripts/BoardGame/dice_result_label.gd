extends Label

func _on_dice_controller_roll_started():
	text = "..."

func _on_dice_controller_roll_finished(value):
	text = "%s" % value
