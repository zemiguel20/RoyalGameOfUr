class_name DiceProbabilities

## This class contians static functions for calculating probabilities for a variaty of dice.

enum DiceType 
{
	Binary = 0,
}

## This function currently only works for binary! Might as well have a seperate function for different dice types.
static func get_probability_of_value(value_to_throw: int, num_of_dice: int = 4, type: DiceType = DiceType.Binary):
	# Chance for one die:
	var num_of_outcomes = _get_num_of_outcomes(type)
	var chance_for_outcome: float = 1.0 / num_of_outcomes
	# Chance for multiple die, were we need to account for combinations:
	var base_chance: float = pow(chance_for_outcome, num_of_dice)
	var num_of_combinations = General.get_combinations(num_of_dice, value_to_throw)    # TODO: This is only true for binary tho
	return base_chance * num_of_combinations
	
## Get the total number of outcomes a dicetype has. 
## Example: Binary has 2, and D6 has 6.
static func _get_num_of_outcomes(type: DiceType):
	if (type == DiceType.Binary):
		return 2
	else:
		push_error("Not Implemented: No number of outcomes implemented for DiceType = ", type)
