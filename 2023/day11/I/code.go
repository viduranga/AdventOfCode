package main

import (
	"fmt"
	"math"
	"os"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func findXXX(data []string) (int, error) {
	row_hist := make([]int, len(data))
	col_hist := make([]int, len(data[0]))

	galaxies := make([][]int, 0)

	for i, line := range data {
		for j, c := range line {
			if c == '#' {
				row_hist[i] += 1
				col_hist[j] += 1

				galaxies = append(galaxies, []int{i, j})
			}
		}
	}

	for _, galaxy := range galaxies {
		row := galaxy[0]
		for i, hist := range row_hist {
			if hist == 0 {
				if galaxy[0] > i {
					row += 1
				}
			}
		}
		galaxy[0] = row
	}

	for _, galaxy := range galaxies {
		col := galaxy[1]
		for i, hist := range col_hist {
			if hist == 0 {
				if galaxy[1] > i {
					col += 1
				}
			}
		}
		galaxy[1] = col
	}

	sum := 0
	for i := 0; i < len(galaxies)-1; i++ {
		for j := i + 1; j < len(galaxies); j++ {
			distance := math.Abs(float64(galaxies[i][0]-galaxies[j][0])) + math.Abs(float64(galaxies[i][1]-galaxies[j][1]))
			sum += int(distance)

		}
	}

	return sum, nil
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
