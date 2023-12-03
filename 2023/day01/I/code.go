package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func findNumbers(data []string) ([]int, error) {
	re := regexp.MustCompile(`^\D*(\d).*?(\d?)\D*$`)

	var result []int

	for _, line := range data {
		match := re.FindStringSubmatch(line)

		if len(match) == 0 {
			return nil, fmt.Errorf("no numbers found in %s", line)
		}
		first, second := match[1], match[2]

		if second == "" {
			second = first
		}
		digit, err := strconv.Atoi(first + second)
		if err != nil {
			return nil, err
		}

		result = append(result, digit)
	}

	return result, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findNumbers(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(util.ArraySum(numbers))
}
