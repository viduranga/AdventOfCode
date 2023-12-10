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

func deepCopy(array [][]int) [][]int {
	result := make([][]int, len(array))
	for i, line := range array {
		result[i] = make([]int, len(line))
		copy(result[i], line)
	}
	return result
}

func visitTiles(r int, c int, visited [][]int) {
	if r < 0 || r >= len(visited) || c < 0 || c >= len(visited[0]) || visited[r][c] != 0 {
		return
	} else {
		visited[r][c] = 2

		visitTiles(r, c+1, visited)
		visitTiles(r, c-1, visited)
		visitTiles(r+1, c, visited)
		visitTiles(r-1, c, visited)
	}
}

func countTiles(visited [][]int) int {
	count := 0

	for i := 0; i < len(visited); i += 3 {
		for j := 0; j < len(visited[0]); j += 3 {
			invalid := false
			for k := 0; k < 3; k++ {
				for l := 0; l < 3; l++ {
					if visited[i+k][j+l] > 1 {
						invalid = true
					}
				}
			}
			if !invalid {
				count++
			}
		}
	}

	return count
}

func findEnclosed(visited [][]int) int {
	for r := 0; r < len(visited); r++ {
		if visited[r][0] == 0 {
			visitTiles(r, 0, visited)
		}
		if visited[r][len(visited[0])-1] == 0 {
			visitTiles(r, len(visited[0])-1, visited)
		}
	}
	for c := 0; c < len(visited[0]); c++ {
		if visited[0][c] == 0 {
			visitTiles(0, c, visited)
		}
		if visited[len(visited)-1][c] == 0 {
			visitTiles(len(visited)-1, c, visited)
		}
	}

	count := countTiles(visited)
	return count
}

func getLoop(r int, c int, from_r int, from_c int, grid [][]int, visited [][]int) bool {
	if visited[r][c] == 2 {
		return grid[r][c] == START
	} else {
		visited[r][c] = 1

		if grid[r][c] == START {
			visited[r][c] = 2
		}

		if grid[r][c] == START || (grid[r][c] == BEND_L && from_c == c) || (grid[r][c] == BEND_F && from_c == c) || (grid[r][c] == STRAIGHT_H && from_c < c) {
			if c < len(grid[0])-1 {

				eligible := true
				if grid[r][c] == START {
					switch grid[r][c+1] {
					case BEND_L, BEND_F, STRAIGHT_V:
						eligible = false
					}
				}
				if eligible {
					loop := getLoop(r, c+1, r, c, grid, visited)

					if loop {
						visited[r][c] = 2
						return true
					}
				}
			}
		}
		if grid[r][c] == START || (grid[r][c] == BEND_J && from_c == c) || (grid[r][c] == BEND_7 && from_c == c) || (grid[r][c] == STRAIGHT_H && from_c > c) {
			if c > 0 {
				eligible := true
				if grid[r][c] == START {
					switch grid[r][c-1] {
					case BEND_J, BEND_7, STRAIGHT_V:
						eligible = false
					}
				}
				if eligible {
					loop := getLoop(r, c-1, r, c, grid, visited)
					if loop {
						visited[r][c] = 2
						return true
					}
				}
			}
		}
		if grid[r][c] == START || (grid[r][c] == BEND_L && from_r == r) || (grid[r][c] == BEND_J && from_r == r) || (grid[r][c] == STRAIGHT_V && from_r > r) {
			if r > 0 {
				eligible := true
				if grid[r][c] == START {
					switch grid[r-1][c] {
					case BEND_L, BEND_J, STRAIGHT_H:
						eligible = false
					}
				}
				if eligible {
					loop := getLoop(r-1, c, r, c, grid, visited)
					if loop {
						visited[r][c] = 2
						return true
					}
				}
			}
		}
		if grid[r][c] == START || (grid[r][c] == BEND_F && from_r == r) || (grid[r][c] == BEND_7 && from_r == r) || (grid[r][c] == STRAIGHT_V && from_r < r) {
			if r < len(grid)-1 {
				eligible := true
				if grid[r][c] == START {
					switch grid[r+1][c] {
					case BEND_7, BEND_F, STRAIGHT_H:
						eligible = false
					}
				}
				if eligible {
					loop := getLoop(r+1, c, r, c, grid, visited)
					if loop {
						visited[r][c] = 2
						return true
					}
				}
			}
		}

		return false
	}
}

func findXXX(data []string) (int, error) {
	grid := make([][]int, len(data))
	visited := make([][]int, len(data))

	s_r, s_c := -1, -1

	for i, line := range data {
		grid[i] = make([]int, len(line))
		visited[i] = make([]int, len(line))
		for j, c := range line {
			visited[i][j] = 0
			switch c {
			case '.':
				grid[i][j] = EMPTY
			case 'S':
				grid[i][j] = START
				s_r, s_c = i, j
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

	visited[s_r][s_c] = 1

	loop := getLoop(s_r, s_c, s_r, s_c, grid, visited)

	_ = loop

	count_visited := make([][]int, len(grid)*3)

	for r := 0; r < len(count_visited); r++ {
		count_visited[r] = make([]int, len(visited[0])*3)
	}

	if s_r > 0 && s_r < len(grid)-1 && visited[s_r-1][s_c] == 2 && visited[s_r+1][s_c] == 2 {
		l_correct, r_correct := false, false
		switch grid[s_r-1][s_c] {
		case STRAIGHT_V, BEND_F, BEND_7:
			l_correct = true
		}
		switch grid[s_r+1][s_c] {
		case STRAIGHT_V, BEND_L, BEND_J:
			r_correct = true
		}

		if l_correct && r_correct {
			grid[s_r][s_c] = STRAIGHT_V
		}
	}

	if s_c > 0 && s_c < len(grid[0])-1 && visited[s_r][s_c-1] == 2 && visited[s_r][s_c+1] == 2 {
		l_correct, r_correct := false, false
		switch grid[s_r][s_c-1] {
		case STRAIGHT_H, BEND_F, BEND_L:
			l_correct = true
		}
		switch grid[s_r][s_c+1] {
		case STRAIGHT_H, BEND_7, BEND_J:
			r_correct = true
		}

		if l_correct && r_correct {
			grid[s_r][s_c] = STRAIGHT_H
		}
	}

	if s_c > 0 && s_r < len(grid)-1 && visited[s_r][s_c-1] == 2 && visited[s_r+1][s_c] == 2 {
		l_correct, r_correct := false, false
		switch grid[s_r][s_c-1] {
		case STRAIGHT_H, BEND_F, BEND_L:
			l_correct = true
		}
		switch grid[s_r+1][s_c] {
		case STRAIGHT_V, BEND_L, BEND_J:
			r_correct = true
		}

		if l_correct && r_correct {
			grid[s_r][s_c] = BEND_7
		}
	}

	if s_c < len(grid[0])-1 && s_r < len(grid)-1 && visited[s_r+1][s_c] == 2 && visited[s_r][s_c+1] == 2 {
		l_correct, r_correct := false, false
		switch grid[s_r+1][s_c] {
		case STRAIGHT_V, BEND_L, BEND_J:
			l_correct = true
		}
		switch grid[s_r][s_c+1] {
		case STRAIGHT_H, BEND_7, BEND_J:
			r_correct = true
		}

		if l_correct && r_correct {
			grid[s_r][s_c] = BEND_F
		}
	}

	if s_c > 0 && s_r > 0 && visited[s_r][s_c-1] == 2 && visited[s_r-1][s_c] == 2 {
		l_correct, r_correct := false, false
		switch grid[s_r][s_c-1] {
		case STRAIGHT_H, BEND_F, BEND_L:
			l_correct = true
		}
		switch grid[s_r-1][s_c] {
		case STRAIGHT_V, BEND_F, BEND_7:
			r_correct = true
		}

		if l_correct && r_correct {
			grid[s_r][s_c] = BEND_J
		}
	}
	if s_c < len(grid[0])-1 && s_r > 0 && visited[s_r][s_c+1] == 2 && visited[s_r-1][s_c] == 2 {
		l_correct, r_correct := false, false
		switch grid[s_r][s_c+1] {
		case STRAIGHT_H, BEND_7, BEND_J:
			l_correct = true
		}
		switch grid[s_r-1][s_c] {
		case STRAIGHT_V, BEND_F, BEND_7:
			r_correct = true
		}

		if l_correct && r_correct {
			grid[s_r][s_c] = BEND_L
		}
	}

	for r := 0; r < len(visited); r++ {
		for c := 0; c < len(visited[0]); c++ {
			if visited[r][c] == 2 {
				switch grid[r][c] {
				case STRAIGHT_H:
					count_visited[r*3+1][c*3] = 2
					count_visited[r*3+1][c*3+1] = 2
					count_visited[r*3+1][c*3+2] = 2
				case STRAIGHT_V:
					count_visited[r*3][c*3+1] = 2
					count_visited[r*3+1][c*3+1] = 2
					count_visited[r*3+2][c*3+1] = 2
				case BEND_L:
					count_visited[r*3][c*3+1] = 2
					count_visited[r*3+1][c*3+1] = 2
					count_visited[r*3+1][c*3+2] = 2
				case BEND_J:
					count_visited[r*3][c*3+1] = 2
					count_visited[r*3+1][c*3] = 2
					count_visited[r*3][c*3+1] = 2
				case BEND_F:
					count_visited[r*3+1][c*3+1] = 2
					count_visited[r*3+1][c*3+2] = 2
					count_visited[r*3+2][c*3+1] = 2
				case BEND_7:
					count_visited[r*3+1][c*3] = 2
					count_visited[r*3+1][c*3+1] = 2
					count_visited[r*3+2][c*3+1] = 2

				}
			}
		}
	}

	enclosed := findEnclosed(count_visited)

	return enclosed, nil
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
