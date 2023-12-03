package aoc_2023_1

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/viduranga/AdventOfCode/util"
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
	lines, err := util.FileToArray(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findNumbers(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(util.arraySum(numbers))
}
