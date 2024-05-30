class_name DiceRoller extends Node3D
## Controls the process of rolling the dice and reading their values.
## Can have automatic throwing, or use input interaction.
## Allows moving dice to rolling zone, as if grabbing them.


signal roll_finished(value: int)
signal dice_placed

@export var automatic: bool = false

var place_spots: Array[Node3D] = []
var throw_spots: Array[Node3D] = []

var last_rolled_value := 0


func _ready() -> void:
	place_spots.assign(get_node(get_meta("placing_spots")).get_children())
	throw_spots.assign(get_node(get_meta("throw_spots")).get_children())


func start(dice: Array[Die]) -> void:
	push_error("NOT IMPLEMENTED") # TODO: activate rolling or selection


## Moves the dice to the placing spots.
## Can be used to animate transfering the dice between players.
func place_dice(dice: Array[Die], skip_animation := false) -> void:
	# Move dice to random spots
	place_spots.shuffle()
	for i in dice.size():
		var die = dice[i]
		var spot = place_spots[i]
		
		var animation = General.MoveAnim.ARC if not skip_animation else General.MoveAnim.NONE
		die.move(spot.global_position, animation)
	
	# Make sure dice are completely still
	for die in dice:
		if die.move_anim.moving:
			await die.move_anim.movement_finished
		
		if not die.sleeping:
			await die.sleeping_state_changed
	
	dice_placed.emit()
