package main

import (
	"fmt"
	"os"

	"github.com/viduranga/AdventOfCode/2023/util"
)

const (
	LEFT  uint = 1
	RIGHT uint = 2
	UP    uint = 4
	DOWN  uint = 8
)

func followBeam(data []string, r, c int, direction uint, state [][]uint) {
	if c < 0 || c >= len(data[0]) || r < 0 || r >= len(data) {
		return
	}

	if state[r][c]&direction == direction {
		return
	}

	state[r][c] |= direction

	switch data[r][c] {
	case '\\':
		switch direction {
		case LEFT:
			followBeam(data, r-1, c, UP, state)
		case RIGHT:
			followBeam(data, r+1, c, DOWN, state)
		case UP:
			followBeam(data, r, c-1, LEFT, state)
		case DOWN:
			followBeam(data, r, c+1, RIGHT, state)
		}
	case '/':
		switch direction {
		case LEFT:
			followBeam(data, r+1, c, DOWN, state)
		case RIGHT:
			followBeam(data, r-1, c, UP, state)
		case UP:
			followBeam(data, r, c+1, RIGHT, state)
		case DOWN:
			followBeam(data, r, c-1, LEFT, state)
		}
	case '|':
		switch direction {
		case LEFT, RIGHT:
			followBeam(data, r-1, c, UP, state)
			followBeam(data, r+1, c, DOWN, state)
		case UP:
			followBeam(data, r-1, c, UP, state)
		case DOWN:
			followBeam(data, r+1, c, DOWN, state)
		}
	case '-':
		switch direction {
		case UP, DOWN:
			followBeam(data, r, c-1, LEFT, state)
			followBeam(data, r, c+1, RIGHT, state)
		case LEFT:
			followBeam(data, r, c-1, LEFT, state)
		case RIGHT:
			followBeam(data, r, c+1, RIGHT, state)
		}
	case '.':
		switch direction {
		case UP:
			followBeam(data, r-1, c, UP, state)
		case DOWN:
			followBeam(data, r+1, c, DOWN, state)
		case LEFT:
			followBeam(data, r, c-1, LEFT, state)
		case RIGHT:
			followBeam(data, r, c+1, RIGHT, state)
		}
	}
}

func totalEnergized(data []string, start_r, start_c int, direction uint) int {
	total := 0

	state := make([][]uint, len(data))
	for i := range state {
		state[i] = make([]uint, len(data[0]))
	}

	followBeam(data, start_r, start_c, direction, state)

	for _, row := range state {
		for _, cell := range row {
			if cell > 0 {
				total++
			}
		}
	}
	return total
}

func findXXX(data []string) (int, error) {
	max_total := 0

	for r := 0; r < len(data); r++ {
		total_1 := totalEnergized(data, r, 0, RIGHT)
		total_2 := totalEnergized(data, r, len(data[0])-1, LEFT)

		total := 0
		if total_1 > total_2 {
			total = total_1
		} else {
			total = total_2
		}

		if total > max_total {
			max_total = total
		}

	}

	for c := 0; c < len(data[0]); c++ {
		total_1 := totalEnergized(data, 0, c, DOWN)
		total_2 := totalEnergized(data, 0, len(data)-1, UP)

		total := 0
		if total_1 > total_2 {
			total = total_1
		} else {
			total = total_2
		}

		if total > max_total {
			max_total = total
		}

	}
	return max_total, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	number, err := findXXX(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(number)
}
