extends Node

func _ready():
	four_binary_value0_test()
	four_binary_value1_test()
	four_binary_value2_test()
	four_binary_value3_test()
	four_binary_value4_test()
	
	one_d6_six_test()
	#two_d6_six_test()
	
func four_binary_value2_test():
	var expected = 6.0/16.0
	var result = DiceProbabilities.get_probability_of_value(2, DiceProbabilities.DiceType.Binary, 4) 
	assert(expected == result, "Result: %d" % result)
	
func four_binary_value1_test():
	var expected = 4.0/16.0
	var result = DiceProbabilities.get_probability_of_value(3, DiceProbabilities.DiceType.Binary, 4) 
	assert(expected == result, "Result: %d" % result)
	
func four_binary_value3_test():
	var expected = 4.0/16.0
	var result = DiceProbabilities.get_probability_of_value(1, DiceProbabilities.DiceType.Binary, 4) 
	assert(expected == result, "Result: %d" % result)
	
func four_binary_value0_test():
	var expected = 1.0/16.0
	var result = DiceProbabilities.get_probability_of_value(0, DiceProbabilities.DiceType.Binary, 4) 
	assert(expected == result, "Result: %d" % result)
	
func four_binary_value4_test():
	var expected = 1.0/16.0
	var result = DiceProbabilities.get_probability_of_value(4, DiceProbabilities.DiceType.Binary, 4) 
	assert(expected == result, "Result: %d" % result)
	
	
func one_d6_six_test():
	var expected = 1.0/6.0
	var result = DiceProbabilities.get_probability_of_value(6, DiceProbabilities.DiceType.D6, 1) 
	assert(expected == result, "Result: %d" % result)


func two_d6_six_test():
	var expected = 5.0/36.0
	var result = DiceProbabilities.get_probability_of_value(6, DiceProbabilities.DiceType.D6, 2) 
	assert(expected == result, "Result: %d" % result)

# Test with catching an error.
#func test_factorial_under_one():
