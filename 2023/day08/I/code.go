package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func findStepsToZZZ(data [][]string) (int, error) {
	directions_str := strings.ReplaceAll(data[0][0], "L", "0")
	directions_str = strings.ReplaceAll(directions_str, "R", "1")

	directions := []int{}
	for i := 0; i < len(directions_str); i++ {
		direction, _ := strconv.Atoi(string(directions_str[i]))
		directions = append(directions, direction)
	}

	locations := make(map[string][]string)

	for _, line := range data[1] {
		from := line[0:3]

		to_left := line[7:10]
		to_right := line[12:15]

		locations[from] = []string{to_left, to_right}
	}

	steps := 0
	current := "AAA"

	for current != "ZZZ" {
		steps++
		direction := directions[(steps-1)%len(directions)]
		current = locations[current][direction]
	}

	return steps, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLineGroups(path)
	if err != nil {
		panic(err)
	}

	number, err := findStepsToZZZ(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(number)
}
