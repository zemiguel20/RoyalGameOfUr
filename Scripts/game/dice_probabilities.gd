class_name DiceProbabilities

## This class contians static functions for calculating probabilities for a variaty of dice.
##
## @tutorial: https://www.onlinemathlearning.com/permutations-math.html

enum DiceType {
	Binary = 0,
	D6
}

static func get_probability_of_value(value_to_throw: int, type: DiceType, num_of_dice: int):
	# Chance for one die:
	var num_of_outcomes = _get_num_of_outcomes(type)
	var chance_for_outcome: float = 1.0 / num_of_outcomes
	# Chance for multiple die, were we need to account for combinations:
	var base_chance: float = pow(chance_for_outcome, num_of_dice)
	var num_of_combinations = _get_combinations(num_of_dice, value_to_throw)    # TODO: This is only true for binary tho
	return base_chance * num_of_combinations
	

static func get_probability_of_four_d4(value: int):
	var num_of_outcomes = 2		# Binary: 0 or 1
	var base_chance_for_outcome = 1 / num_of_outcomes
	var base_chance = pow(base_chance_for_outcome, 4)
	var num_of_combinations = _get_combinations(4, 2)
	print("Com: ", num_of_combinations)
	return base_chance * num_of_combinations
	
	
static func _get_num_of_outcomes(type: DiceType):
	if (type == DiceType.Binary):
		return 2
	elif (type == DiceType.D6):
		return 6
	else:
		push_error("Not Implemented: No number of outcomes implemented for DiceType = ", type)
		

## Calculates the combinations:	
## The number of ways to choose a sample of r elements from a set of n distinct objects 
## where order does not matter and replacements are not allowed.
static func _get_combinations(n: int, r: int):
	if (n <= r or n <= 0 or r <= 0):
		return 1
	
	# Mathematical function for calculating combinations.
	return _factorial(n)/(_factorial(n-r) * _factorial(r))
	
	
## Get the factorial of n.
## Example for n = 6: n! = 6 * 5 * 4 * 3 * 2 * 1 = 720
static func _factorial(n: int):
	if (n < 1):
		push_error("Invalid Argument: Can not get the factorial for n = ", n)
		return -1
	elif (n == 1):
		return 1
		
	return n * _factorial(n - 1)
	
