package main

import (
	"os"
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

	second_map := make(map[int]int)
	for _, line := range lines {
		nums := strings.Fields(line)

		first_num, _ := strconv.Atoi(nums[0])
		second_num, _ := strconv.Atoi(nums[1])

		first = append(first, first_num)

		second_map[second_num] += 1
	}

	similarity := 0

	for _, first_num := range first {
		similarity += first_num * second_map[first_num]
	}

	println(similarity)

}
