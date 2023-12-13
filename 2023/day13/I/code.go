package main

import (
	"fmt"
	"os"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func findXXX(groups [][]string) (int, error) {
	total := 0
	horizontal_mirror := 0
	vertical_mirror := 0

	for _, data := range groups {

		vdata := make([]string, 0)

		for i := 0; i < len(data[0]); i++ {
			column := make([]byte, 0)
			for j := 0; j < len(data); j++ {
				column = append(column, data[j][i])
			}
			vdata = append(vdata, string(column))
		}

		for i := 0; i < len(data)-1; i++ {
			mirrored := true
			for j := 0; j <= i; j++ {
				k := (i - j) + i + 1
				if k < len(data) && data[j] != data[k] {
					mirrored = false
				}
			}
			if mirrored {
				horizontal_mirror += i + 1
				break
			}

		}

		for i := 0; i < len(vdata)-1; i++ {
			mirrored := true
			for j := 0; j <= i; j++ {
				k := (i - j) + i + 1
				if k < len(vdata) && vdata[j] != vdata[k] {
					mirrored = false
				}
			}
			if mirrored {
				vertical_mirror += i + 1
				break
			}

		}
	}

	total = vertical_mirror + horizontal_mirror*100

	return total, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLineGroups(path)
	if err != nil {
		panic(err)
	}

	number, err := findXXX(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(number)
}
