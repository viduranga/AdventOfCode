package main

import (
	"fmt"
	"os"
	"strconv"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func smugged(bits uint64) bool {
	return (bits & (bits - 1)) == 0
}

func findMirror(data []uint64) int {
	for i := 0; i < len(data)-1; i++ {
		mirrored := true
		smudge := false
		for j := 0; j <= i; j++ {
			k := (i - j) + i + 1
			if k < len(data) {
				if data[j] == data[k] {
					continue
				} else if smugged(data[j] ^ data[k]) {
					if !smudge {
						smudge = true
						continue
					} else {
						mirrored = false
						break
					}
				} else {
					mirrored = false
					break
				}
			}
		}
		if mirrored && smudge {
			return i + 1
		}

	}
	return 0
}

func findXXX(groups [][]string) (int, error) {
	total := 0
	horizontal_mirror := 0
	vertical_mirror := 0

	for _, data_str := range groups {

		vdata := make([]uint64, 0)
		data := make([]uint64, 0)

		for i := 0; i < len(data_str); i++ {
			line := ""
			for j := 0; j < len(data_str[0]); j++ {
				if data_str[i][j] == '#' {
					line += "1"
				} else {
					line += "0"
				}
			}
			val, _ := strconv.ParseUint(line, 2, 64)
			data = append(data, val)
		}

		for i := 0; i < len(data_str[0]); i++ {
			line := ""
			for j := 0; j < len(data_str); j++ {
				if data_str[j][i] == '#' {
					line += "1"
				} else {
					line += "0"
				}
			}
			val, _ := strconv.ParseUint(line, 2, 64)
			vdata = append(vdata, val)
		}

		horizontal_mirror += findMirror(data)
		vertical_mirror += findMirror(vdata)
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
