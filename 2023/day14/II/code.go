package main

import (
	"fmt"
	"os"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func tilt_north(data [][]rune) {
	for i := 0; i < len(data[0]); i++ {
		row := 0
		for j := 0; j < len(data); j++ {
			if data[j][i] == '#' {
				row = j + 1
			} else if data[j][i] == 'O' {
				data[j][i] = '.'
				data[row][i] = 'O'
				row++
			}
		}
	}
}

func tilt_south(data [][]rune) {
	for i := 0; i < len(data[0]); i++ {
		row := len(data) - 1
		for j := len(data) - 1; j >= 0; j-- {
			if data[j][i] == '#' {
				row = j - 1
			} else if data[j][i] == 'O' {
				data[j][i] = '.'
				data[row][i] = 'O'
				row--
			}
		}
	}
}

func tilt_west(data [][]rune) {
	for i := 0; i < len(data); i++ {
		col := 0
		for j := 0; j < len(data[0]); j++ {
			if data[i][j] == '#' {
				col = j + 1
			} else if data[i][j] == 'O' {
				data[i][j] = '.'
				data[i][col] = 'O'
				col++
			}
		}
	}
}

func tilt_east(data [][]rune) {
	for i := 0; i < len(data); i++ {
		col := len(data[0]) - 1
		for j := len(data[0]) - 1; j >= 0; j-- {
			if data[i][j] == '#' {
				col = j - 1
			} else if data[i][j] == 'O' {
				data[i][j] = '.'
				data[i][col] = 'O'
				col--
			}
		}
	}
}

func calculateLoad(data [][]rune) int {
	total := 0
	rows := len(data)
	for i := 0; i < len(data); i++ {
		for j := 0; j < len(data[0]); j++ {
			if data[i][j] == 'O' {
				total += (rows - i)
			}
		}
	}
	return total
}

type Result struct {
	data [][]rune
}

func findXXX(data_str []string) (int, error) {
	total := 0

	data := make([][]rune, 0)

	for _, line := range data_str {
		data = append(data, []rune(line))
	}

	load_map := make(map[int][]int)

	results := make([]Result, 0)

	for i := 0; i < 1_000_000_000; i++ {
		tilt_north(data)
		tilt_west(data)
		tilt_south(data)
		tilt_east(data)

		load := calculateLoad(data)

		prev_results, ok := load_map[load]

		if ok {
			for _, prev := range prev_results {
				if util.Array2dEquals[rune](results[prev].data, data) {
					potential_setup_id := (1_000_000_000-prev)%(i-prev) + prev - 1
					return calculateLoad(results[potential_setup_id].data), nil
				}
			}
		}

		load_map[load] = append(load_map[load], i)
		results = append(results, Result{data: util.Array2dDeepCopy[rune](data)})
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
