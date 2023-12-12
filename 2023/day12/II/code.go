package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

var possibilities_map map[[3]int]int

func possibilities(line []rune, groups []int, i int, gi int, gcount int) int {
	cache, ok := possibilities_map[[3]int{i, gcount, gi}]
	if ok {
		return cache
	}
	count := 0
	if i == len(line) {
		if gi == len(groups) || (gi == len(groups)-1 && groups[gi] == 0) {
			count = 1
		} else {
			count = 0
		}
	} else if gi == len(groups) {
		if line[i] == '.' {
			count = possibilities(line, groups, i+1, gi, gcount)
		} else if line[i] == '?' {
			line[i] = '.'
			count = possibilities(line, groups, i+1, gi, gcount)
		} else {
			count = 0
		}
	} else if len(line)-i < gcount {
		count = 0
	} else {
		switch line[i] {

		case '?':
			if groups[gi] == 0 {
				option1 := make([]rune, len(line))
				copy(option1, line)
				option1[i] = '.'
				count += possibilities(option1, groups, i+1, gi+1, gcount)
			} else if i == 0 || line[i-1] == '.' {
				option1 := make([]rune, len(line))
				copy(option1, line)
				option1[i] = '.'
				count += possibilities(option1, groups, i+1, gi, gcount)
			}

			if groups[gi] >= 1 {
				option2 := make([]rune, len(line))
				copy(option2, line)
				option2[i] = '#'

				groups_cpy := make([]int, len(groups))
				copy(groups_cpy, groups)
				groups_cpy[gi] -= 1

				count += possibilities(option2, groups_cpy, i+1, gi, gcount-1)
			}
		case '.':
			if i > 0 && line[i-1] == '#' {
				if groups[gi] == 0 {
					count += possibilities(line, groups, i+1, gi+1, gcount)
				} else {
					count = 0
				}
			} else {
				count += possibilities(line, groups, i+1, gi, gcount)
			}
		default:
			if groups[gi] == 0 {
				count = 0
			} else {

				groups_cpy := make([]int, len(groups))
				copy(groups_cpy, groups)
				groups_cpy[gi] -= 1
				count += possibilities(line, groups_cpy, i+1, gi, gcount-1)
			}
		}
	}

	possibilities_map[[3]int{i, gcount, gi}] = count
	return count
}

func findXXX(data []string) (int64, error) {
	total := int64(0)
	for i, line := range data {
		possibilities_map = make(map[[3]int]int)
		fmt.Println(i)
		split := strings.Split(line, " ")

		pattern := split[0]
		groups_str := strings.Split(split[1], ",")

		groups := make([]int, 0)
		for _, group_str := range groups_str {
			group, _ := strconv.Atoi(group_str)
			groups = append(groups, group)
		}

		long_pattern := pattern

		groups_count := len(groups)
		for j := 0; j < 4; j++ {
			for i := 0; i < groups_count; i++ {
				groups = append(groups, groups[i])
			}
			long_pattern += "?" + pattern
		}

		count := possibilities([]rune(long_pattern), groups, 0, 0, util.ArraySum(groups))

		total += int64(count)

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
