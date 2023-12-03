package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func isSymbolAvailable(symbol_re *regexp.Regexp, data []string, start int, end int, row int) bool {
	if start < 0 {
		start = 0
	}
	if end > len(data[row]) {
		end = len(data[row])
	}

	for i := row - 1; i <= row+1; i++ {
		if i < 0 || i >= len(data) {
			continue
		}
		if symbol_re.MatchString(data[i][start:end]) {
			return true
		}
	}
	return false
}

func findPartNumbers(data []string) ([]int, error) {
	number_re := regexp.MustCompile(`(\d+)`)

	symbol_re := regexp.MustCompile(`[^0-9\.]`)

	var result []int

	for row, line := range data {

		number_match := number_re.FindAllStringIndex(line, -1)

		for _, match := range number_match {
			number, err := strconv.Atoi(line[match[0]:match[1]])
			if err != nil {
				return nil, err
			}

			if isSymbolAvailable(symbol_re, data, match[0]-1, match[1]+1, row) {
				result = append(result, number)
			}
		}
	}
	return result, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findPartNumbers(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(util.ArraySum(numbers))
}
