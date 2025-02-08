class_name Maths
## Contains global math constants and functions that are not present as built-in.


## Probability mass function. Variable must follow a binomial distribution (2 possible outcomes).
##
## [param k] is the number of successes in [param n] trials, with [param p] being the \
## chance of success in a trial.
static func calculate_probability(k: int, n: int, p: float) -> float:
	if k < 0 or n < 0 or p < 0.0:
		push_error("Parameters must be positive.")
		return 0.0
	if k > n:
		push_error("K cannot be higher than N.")
		return 0.0
	if p > 1.0:
		push_error("P cannot be higher than 1.0 (=100%).")
		return 0.0
	
	return binom_coef(k, n) * pow(p, k) * pow(1 - p, n - k)


## Calculates the binomial coeffient
static func binom_coef(k: int, n: int) -> float:
	return float(factorial(n)) / float((factorial(k) * factorial(n-k)))


static func factorial(n: int) -> int:
	if n < 0:
		push_error("N must be positive.")
		return -1
	
	if n == 1 or n == 0:
		return 1
	
	return n * factorial(n - 1)
