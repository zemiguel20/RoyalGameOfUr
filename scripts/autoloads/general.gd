extends Node
## Contains constants and general utility functions


enum Player {ONE = 0, TWO = 1} ## Player IDs

## Types of simple movement animations.
enum MoveAnim {
	ARC, ## Moves from point A to B in a arc.
	LINE, ## Moves directly from point A to B.
	NONE, ## No animation. Movement is instantaneous.
}

const PIECE_OFFSET_Y = 0.15 ## Offset for stacking. Easier than calculating offset using AABB.


func get_opponent(player : Player) -> Player:
	return Player.ONE if player == Player.TWO else Player.TWO


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
