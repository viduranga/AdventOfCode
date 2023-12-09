package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func findWeathePrediction(data []string) ([]int, error) {
	var result []int

	for _, line := range data {
		split := strings.Split(line, " ")

		var numbers []int
		for _, number_str := range split {
			number, err := strconv.Atoi(number_str)
			if err != nil {
				continue
			}
			numbers = append(numbers, number)
		}

		var diff_lists [][]int

		diff_lists = append(diff_lists, numbers)

		for i := 0; i < len(numbers)-1; i++ {

			zero_count := 0

			diff_list := diff_lists[i]
			diff_lists = append(diff_lists, []int{})
			for j := 0; j < len(diff_list)-1; j++ {
				diff := diff_list[j+1] - diff_list[j]
				diff_lists[i+1] = append(diff_lists[i+1], diff)
				if diff == 0 {
					zero_count++
				}
			}

			if zero_count == len(diff_list)-1 {
				break
			}
		}

		prediction := 0

		for i := len(diff_lists) - 1; i >= 0; i-- {
			prediction = diff_lists[i][0] - prediction
		}
		result = append(result, prediction)
	}

	return result, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findWeathePrediction(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(util.ArraySum(numbers))
}
