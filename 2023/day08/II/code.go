package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func locationToIndex(location string) int {
	index := (int(location[2]) - 65) + (int(location[1])-65)*26 + (int(location[0])-65)*26*26

	if location[2] == 'Z' {
		return index * -1
	}
	return index
}

func findStepsToZZZ(data [][]string) ([]int, error) {
	directions_str := strings.ReplaceAll(data[0][0], "L", "0")
	directions_str = strings.ReplaceAll(directions_str, "R", "1")

	directions := []int{}
	for i := 0; i < len(directions_str); i++ {
		direction, _ := strconv.Atoi(string(directions_str[i]))
		directions = append(directions, direction)
	}

	locations := make(map[int][]int)

	currents := []int{}

	for _, line := range data[1] {
		from := locationToIndex(line[0:3])

		to_left := locationToIndex(line[7:10])
		to_right := locationToIndex(line[12:15])

		if line[2] == 'A' {
			currents = append(currents, from)
		}

		locations[from] = []int{to_left, to_right}
	}

	currents_count := len(currents)
	directions_count := len(directions)

	var step int = 0
	var round int = 0

	z_after := make([]int, currents_count)
	z_last := make([]int, currents_count)
	z_loop_count := 0

	for {
		direction := directions[step]
		step++
		if step >= directions_count {
			step = 0
			round++
		}

		for i, current := range currents {
			current = locations[current][direction]
			currents[i] = current
			if current < 0 {
				z_after[i] = step + directions_count*round - z_last[i]
				z_last[i] = step + directions_count*round
				z_loop_count++
			}
		}

		if z_loop_count == currents_count {
			break
		}

	}
	return z_after, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLineGroups(path)
	if err != nil {
		panic(err)
	}

	z_loops, err := findStepsToZZZ(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(util.LCM(z_loops[0], z_loops[1], z_loops[2:]...))
}
