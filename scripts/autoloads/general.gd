extends Node
## Contains constants and general utility functions


enum Player {ONE = 0, TWO = 1}


# Not tested yet.
static func get_random_position_in_boxshape_3D(shape : BoxShape3D) -> Vector3:
	var random_position = Vector3()
	random_position.x = randi_range(shape.position - shape.size.x/2, shape.position + shape.size.x/2)
	random_position.z = randi_range(shape.position - shape.size.z/2, shape.position + shape.size.z/2)
	return random_position


## NOTE I could also move these mathematical function into its own MathExtensions class.

## Calculates the combinations:	
## The number of ways to choose a sample of r elements from a set of n distinct objects 
## where order does not matter and replacements are not allowed.
## @tutorial: https://www.onlinemathlearning.com/permutations-math.html
static func get_combinations(n: int, r: int):
	if n < r or n < 0 or r < 0:
		push_error("Invalid Argument: Please enter values where n >= r >= 0")
		return -1
	
	# Mathematical function for calculating combinations.
	return factorial(n)/(factorial(n-r) * factorial(r))
	
	
## Get the factorial of n.
## Example for n = 6: n! = 6 * 5 * 4 * 3 * 2 * 1 = 720
static func factorial(n: int):
	if n < 0:
		push_error("Invalid Argument: Can not get the factorial for n = ", n)
		return -1
	elif n == 1 or n == 0:
		return 1
		
	return n * factorial(n - 1)
