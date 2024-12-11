class_name General
## Contains global constants and utility functions.


enum Player {
	ONE,
	TWO,
}


const RULESET_FINKEL = preload("res://resources/rulesets/ruleset_finkel.tres")
const RULESET_MASTERS = preload("res://resources/rulesets/ruleset_masters.tres")
const RULESET_BLITZ = preload("res://resources/rulesets/ruleset_blitz.tres")
const RULESET_TOURNAMENT = preload("res://resources/rulesets/ruleset_tournament.tres")
const RULESET_RR = preload("res://resources/rulesets/ruleset_russian_rosette.tres")

const BOARD_FINKEL = preload("res://resources/rulesets/board_layouts/layout_finkel.tres")
const BOARD_MASTERS = preload("res://resources/rulesets/board_layouts/layout_masters.tres")
const BOARD_RR = preload("res://resources/rulesets/board_layouts/layout_russian_rosette.tres")


func get_opponent(player : Player) -> Player:
	return Player.ONE if player == Player.TWO else Player.TWO

func get_random_player() -> Player:
	return randi_range(Player.ONE, Player.TWO) as Player

## This is a quick helper function for converting an euler rotation from degrees to radians.
func deg_to_rad(vector: Vector3):
	return Vector3(deg_to_rad(vector.x), deg_to_rad(vector.y), deg_to_rad(vector.z))


## Returns the probability of throwing a specific value with a certain number of dice, 0-1.
## Based on coin flip probability formula: (n! / k!(n-k)!) / 2^n .
##
## [param k] is the value to throw, and [param n] is the number of dice.
func get_probability_of_value(k: int, n: int = 4) -> float:
	return factorial(n) / (factorial(k) * factorial(n-k)) / pow(2.0, n)


func factorial(n: int):
	if n < 0:
		push_error("Invalid Argument: Can not get the factorial for n = ", n)
		return -1
	elif n == 1 or n == 0:
		return 1
		
	return n * factorial(n - 1)


## Generates a random euler rotation.
func get_random_rotation() -> Vector3:
	var angle_x = randf_range(-PI, PI)
	var angle_y = randf_range(-PI, PI)
	var angle_z = randf_range(-PI, PI)
	return Vector3(angle_x, angle_y, angle_z)
