package util

func arraySum(numbers []int) int {
	var result int
	for _, number := range numbers {
		result += number
	}
	return result
}
