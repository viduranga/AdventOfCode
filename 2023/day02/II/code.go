package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func findPossibleGames(data []string, colors []string) ([]int, error) {
	var color_count_re map[string]*regexp.Regexp = make(map[string]*regexp.Regexp)

	for _, color := range colors {
		color_count_re[color] = regexp.MustCompile(fmt.Sprintf(`(\d+) %s`, color))
	}

	var result []int

	for _, line := range data {
		splits := strings.Split(line, ": ")

		rounds := strings.Split(splits[1], ";")

		max_required := make(map[string]int)
		for _, round := range rounds {
			for color, re := range color_count_re {
				count_match := re.FindStringSubmatch(round)
				if len(count_match) < 2 {
					continue
				}

				count, err := strconv.Atoi(count_match[1])
				if err != nil {
					return nil, err
				}

				max_required[color] = max(max_required[color], count)
			}
		}

		var power int = 1
		for _, color := range colors {
			power *= max_required[color]
		}
		result = append(result, power)
	}

	return result, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findPossibleGames(lines, []string{"red", "green", "blue"})
	if err != nil {
		panic(err)
	}

	fmt.Println(util.ArraySum(numbers))
}
