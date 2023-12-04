package main

import (
	"fmt"
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

func findCardInstances(data []string) ([]int, error) {
	instances := make([]int, len(data))

	for i, line := range data {

		// Increment once for the original scratch card
		instances[i]++

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

		for j := 0; j < ins; j++ {
			// Increment the instances of winning cards
			// by the number of instances of the current card
			instances[i+j+1] += instances[i]
		}
	}
	return instances, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findCardInstances(lines)
	if err != nil {
		panic(err)
	}
	fmt.Println(numbers)

	fmt.Println(util.ArraySum(numbers))
}
