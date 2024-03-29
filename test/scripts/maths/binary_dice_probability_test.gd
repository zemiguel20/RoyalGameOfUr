extends Node

func _ready():
	four_binary_tests()
	print("All tests successfull!")
	
func four_binary_tests():
	# TEST: Chance to throw 0
	var expected = 1.0/16.0
	var result = DiceProbabilities.get_probability_of_value(0, 4, DiceProbabilities.DiceType.Binary) 
	assert(expected == result, "Result: %d" % result)
	
	# TEST: Chance to throw 1	
	expected = 4.0/16.0
	result = DiceProbabilities.get_probability_of_value(3, 4, DiceProbabilities.DiceType.Binary) 
	assert(expected == result, "Result: %d" % result)
	
	# TEST: Chance to throw 2	
	expected = 6.0/16.0
	result = DiceProbabilities.get_probability_of_value(2, 4, DiceProbabilities.DiceType.Binary) 
	assert(expected == result, "Result: %d" % result)
	
	# TEST: Chance to throw 3	
	expected = 4.0/16.0
	result = DiceProbabilities.get_probability_of_value(1, 4, DiceProbabilities.DiceType.Binary) 
	assert(expected == result, "Result: %d" % result)
	
	# TEST: Chance to throw 4	
	expected = 1.0/16.0
	result = DiceProbabilities.get_probability_of_value(4, 4, DiceProbabilities.DiceType.Binary) 
	assert(expected == result, "Result: %d" % result)
	
	
#func one_d6_six_test():
	#var expected = 1.0/6.0
	#var result = DiceProbabilities.get_probability_of_value(6, 1, DiceProbabilities.DiceType.D6) 
	#assert(expected == result, "Result: %d" % result)
#
#
#func two_d6_six_test():
	#var expected = 5.0/36.0
	#var result = DiceProbabilities.get_probability_of_value(6, 2, DiceProbabilities.DiceType.D6) 
	#assert(expected == result, "Result: %d" % result)
