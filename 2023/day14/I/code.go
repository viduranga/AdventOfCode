package main

import (
	"fmt"
	"os"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func findXXX(data []string) (int, error) {
	total := 0

	for i := 0; i < len(data[0]); i++ {
		row := len(data)
		for j := 0; j < len(data); j++ {
			if data[j][i] == '#' {
				row = len(data) - (j + 1)
			} else if data[j][i] == 'O' {
				total += row
				row -= 1
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
