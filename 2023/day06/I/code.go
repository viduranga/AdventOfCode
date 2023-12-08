package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func findWinnables(data []string) (int, error) {
	var matches map[int]int = make(map[int]int)

	re := regexp.MustCompile(`(\d+)`)
	times := re.FindAllString(data[0][9:], -1)
	distances := re.FindAllString(data[1][9:], -1)

	for i, time := range times {
		t, err := strconv.Atoi(time)
		if err != nil {
			return -1, err
		}
		d, err := strconv.Atoi(distances[i])
		if err != nil {
			return -1, err
		}
		matches[t] = d
	}

	result := 1
	for time, distance := range matches {

		winnable := 0

		for charge := 0; charge <= time; charge++ {
			time_left := time - charge
			traveled := time_left * charge

			if traveled > distance {
				winnable++
			}
		}

		result *= winnable
	}

	return result, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findWinnables(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(numbers)
}
