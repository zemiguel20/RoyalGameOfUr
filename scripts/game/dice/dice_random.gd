class_name MockDice
extends Dice

func _ready():
	pass


func on_roll_phase_started(player):
	value = randi_range(0, 4)
	print("Player %d rolled %d" % [player, value])
	roll_finished.emit(value)
