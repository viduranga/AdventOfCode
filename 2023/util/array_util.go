package util

import (
	"math"
)

func Array2dDeepCopy[T int | bool | rune](array [][]T) [][]T {
	result := make([][]T, len(array))
	for i, line := range array {
		result[i] = make([]T, len(line))
		copy(result[i], line)
	}
	return result
}

func Array2dEquals[T comparable](first [][]T, second [][]T) bool {
	if len(first) != len(second) {
		return false
	}
	for i := 0; i < len(first); i++ {
		if len(first[i]) != len(second[i]) {
			return false
		}
		for j := 0; j < len(first[i]); j++ {
			if first[i][j] != second[i][j] {
				return false
			}
		}
	}
	return true
}

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
