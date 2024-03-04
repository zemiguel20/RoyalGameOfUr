class_name DiceProbabilities

## This class contians static functions for calculating probabilities for a variaty of dice.
##
## @tutorial: https://www.onlinemathlearning.com/permutations-math.html

enum DiceType {
    Binary = 0,
}

static func get_probability_of_value(value_to_throw: int, type: DiceType, num_of_dice: int):
    # Chance for one die:
    var num_of_outcomes = _get_num_of_outcomes(type)
    var chance_for_outcome = 1 / num_of_outcomes
    # Chance for multiple die, were we need to account for combinations:
    var base_chance = pow(chance_for_outcome, num_of_dice)
    var num_of_combinations = _get_combinations(num_of_dice, value_to_throw)
    return base_chance * num_of_combinations
    

static func get_probability_of_four_d4(value: int):
    var num_of_outcomes = 2		# Binary: 0 or 1
    var base_chance_for_outcome = 1 / num_of_outcomes
    var base_chance = pow(base_chance_for_outcome, 4)
    var num_of_combinations = _get_combinations(4, 2)
    return base_chance * num_of_combinations
    
    
static func _get_num_of_outcomes(type: DiceType):
    if (type == DiceType.Binary):
        return 2
    else:
        push_error("Not Implemented: No number of outcomes implemented for DiceType = ", type)
        

    
static func _get_combinations(n: int, r: int):
    # Mathematical function for calculating combinations.
    return _factorial(n)/((_factorial(n) - _factorial(r)) * _factorial(r))
    
    
## Get the factorial of n.
## Example for n = 6: n! = 6 * 5 * 4 * 3 * 2 * 1 = 720
static func _factorial(n: int):
    if (n < 1):
        push_error("Invalid Argument: Can not get the factorial for n = ", n)
    elif (n == 1):
        return 1
        
    return n * _factorial(n - 1)
    
