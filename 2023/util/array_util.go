package util

import (
	"math"
)

func ArraySum(numbers []int) int {
	var result int
	for _, number := range numbers {
		result += number
	}
	return result
}

func ArrayMin(numbers []int) int {
	var result int = math.MaxInt32
	for _, number := range numbers {
		if number < result {
			result = number
		}
	}
	return result
}

func ArrayMax(numbers []int) int {
	var result int = 0
	for _, number := range numbers {
		if number > result {
			result = number
		}
	}
	return result
}
