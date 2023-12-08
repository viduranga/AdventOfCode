package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func findWinnables(data []string) (int, error) {
	re := regexp.MustCompile(`(\d+)`)
	times := re.FindAllString(data[0][9:], -1)
	distances := re.FindAllString(data[1][9:], -1)

	time, _ := strconv.Atoi(strings.Join(times[:], ""))
	distance, _ := strconv.Atoi(strings.Join(distances[:], ""))

	winnable := 0

	for charge := 0; charge <= time; charge++ {
		time_left := time - charge
		traveled := time_left * charge

		if traveled > distance {
			winnable++
		}
	}

	return winnable, nil
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
