package main

import (
	"fmt"
	"os"

	"github.com/viduranga/AdventOfCode/2023/util"
)

const (
	EMPTY      int = 0
	START          = 1
	BEND_L         = 2
	BEND_J         = 3
	BEND_F         = 4
	BEND_7         = 5
	STRAIGHT_V     = 6
	STRAIGHT_H     = 7
)

func deepCopy(array [][]bool) [][]bool {
	result := make([][]bool, len(array))
	for i, line := range array {
		result[i] = make([]bool, len(line))
		copy(result[i], line)
	}
	return result
}

func getLoop(r int, c int, from_r int, from_c int, grid [][]int, visited [][]bool) ([]int, bool) {
	if visited[r][c] {
		return []int{}, grid[r][c] == START
	} else {
		visited[r][c] = true

		if grid[r][c] == START || (grid[r][c] == BEND_L && from_c == c) || (grid[r][c] == BEND_F && from_c == c) || (grid[r][c] == STRAIGHT_H && from_c < c) {
			if c < len(grid[0])-1 {
				result, loop := getLoop(r, c+1, r, c, grid, deepCopy(visited))

				if loop {
					return append(result, grid[r][c]), true
				}
			}
		}
		if grid[r][c] == START || (grid[r][c] == BEND_J && from_c == c) || (grid[r][c] == BEND_7 && from_c == c) || (grid[r][c] == STRAIGHT_H && from_c > c) {
			if c > 0 {
				result, loop := getLoop(r, c-1, r, c, grid, deepCopy(visited))
				if loop {
					return append(result, grid[r][c]), true
				}
			}
		}
		if grid[r][c] == START || (grid[r][c] == BEND_L && from_r == r) || (grid[r][c] == BEND_J && from_r == r) || (grid[r][c] == STRAIGHT_V && from_r > r) {
			if r > 0 {
				result, loop := getLoop(r-1, c, r, c, grid, deepCopy(visited))
				if loop {
					return append(result, grid[r][c]), true
				}
			}
		}
		if grid[r][c] == START || (grid[r][c] == BEND_F && from_r == r) || (grid[r][c] == BEND_7 && from_r == r) || (grid[r][c] == STRAIGHT_V && from_r < r) {
			if c < len(grid)-1 {
				result, loop := getLoop(r+1, c, r, c, grid, deepCopy(visited))
				if loop {
					return append(result, grid[r][c]), true
				}
			}
		}

		return []int{}, false
	}
}

func findXXX(data []string) (int, error) {
	grid := make([][]int, len(data))
	visited := make([][]bool, len(data))

	s_x, s_y := -1, -1

	for i, line := range data {
		grid[i] = make([]int, len(line))
		visited[i] = make([]bool, len(line))
		for j, c := range line {
			visited[i][j] = false
			switch c {
			case '.':
				grid[i][j] = EMPTY
			case 'S':
				grid[i][j] = START
				s_x, s_y = i, j
			case 'L':
				grid[i][j] = BEND_L
			case 'J':
				grid[i][j] = BEND_J
			case 'F':
				grid[i][j] = BEND_F
			case '7':
				grid[i][j] = BEND_7
			case '|':
				grid[i][j] = STRAIGHT_V
			case '-':
				grid[i][j] = STRAIGHT_H
			}
		}
	}

	fmt.Println(grid)

	loop, _ := getLoop(s_x, s_y, s_x, s_y, grid, visited)
	return len(loop) / 2, nil
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
