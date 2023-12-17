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

func findXXX(data []string) (int, error) {
	total := 0

	state := make([][]uint, len(data))
	for i := range state {
		state[i] = make([]uint, len(data[0]))
	}

	followBeam(data, 0, 0, RIGHT, state)

	for _, row := range state {
		for _, cell := range row {
			if cell > 0 {
				total++
			}
		}
	}

	return total, nil
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
