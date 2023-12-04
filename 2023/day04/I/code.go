package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func isIn(value int, array []int) bool {
	for _, v := range array {
		if v == value {
			return true
		}
	}
	return false
}

func findWinnings(data []string) ([]int, error) {
	var result []int

	for _, line := range data {

		split := strings.Split(line[8:], "|")

		left := strings.Split(split[0], " ")
		right := strings.Split(split[1], " ")

		var winnings []int
		var mines []int

		for _, winning := range left {
			number, err := strconv.Atoi(winning)
			if err != nil {
				continue
			}
			winnings = append(winnings, number)
		}
		for _, mine := range right {
			number, err := strconv.Atoi(mine)
			if err != nil {
				continue
			}
			mines = append(mines, number)
		}

		ins := 0

		for _, mine := range mines {
			if isIn(mine, winnings) {
				ins++
			}
		}

		if ins > 0 {
			result = append(result, int(math.Pow(2, float64(ins-1))))
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

	numbers, err := findWinnings(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(util.ArraySum(numbers))
}
