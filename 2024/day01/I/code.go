package main

import (
	"os"
	"sort"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/util"
)

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)

	if err != nil {
		panic(err)
	}

	first := make([]int, 0)
	second := make([]int, 0)
	for _, line := range lines {
		nums := strings.Fields(line)

		first_num, _ := strconv.Atoi(nums[0])
		second_num, _ := strconv.Atoi(nums[1])

		first = append(first, first_num)
		second = append(second, second_num)

	}

	sort.Ints(first)
	sort.Ints(second)

	distance := 0
	for i, first_num := range first {
		second_num := second[i]
		if first_num > second_num {
			first_num, second_num = second_num, first_num
		}

		distance += second_num - first_num
	}

	println(distance)

}
