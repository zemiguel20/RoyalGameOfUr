class_name AutoRollController
extends RollController
## Automatically shakes the dice for a certain duration and tosses.


const DELAY_GRAB_DICE: float = 0.5
const MIN_SHAKE_DURATION: float = 0.5
const MAX_SHAKE_DURATION: float = 2.0


func _start_toss_procedure() -> void:
	await get_tree().create_timer(DELAY_GRAB_DICE).timeout
	_start_shaking()
	var shake_duration = randf_range(MIN_SHAKE_DURATION, MAX_SHAKE_DURATION)
	await get_tree().create_timer(shake_duration).timeout
	_stop_shaking()
