package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func permutations(line string, i int, broken_count int) []string {
	// fmt.Println(line, i, broken_count)
	perm := make([]string, 0)
	if i == len(line) {
		return []string{line}
	}
	if line[i] == '?' {
		option1 := line[:i] + "." + line[i+1:]
		perm = append(perm, permutations(option1, i+1, broken_count)...)

		if broken_count > 0 {
			option2 := line[:i] + "#" + line[i+1:]
			perm = append(perm, permutations(option2, i+1, broken_count-1)...)
		}
	} else {
		perm = append(perm, permutations(line, i+1, broken_count)...)
	}

	return perm
}

func groupMatchCount(line string, groups []int) int {
	// fmt.Println(line, groups)
	regex := "^\\.*"
	for i := 0; i < len(groups)-1; i++ {
		regex += fmt.Sprintf("#{%d}\\.+", groups[i])
	}
	regex += fmt.Sprintf("#{%d}\\.*$", groups[len(groups)-1])
	pattern := regexp.MustCompile(regex)

	// fmt.Println(regex)
	count := 0
	for _, perm := range permutations(line, 0, util.ArraySum(groups)) {
		if pattern.MatchString(perm) {
			// fmt.Println(perm)
			count += 1
		}
	}

	return count
}

func findXXX(data []string) (int, error) {
	total := 0
	for _, line := range data {
		split := strings.Split(line, " ")

		pattern := split[0]
		groups_str := strings.Split(split[1], ",")

		groups := make([]int, 0)
		for _, group_str := range groups_str {
			group, _ := strconv.Atoi(group_str)
			groups = append(groups, group)
		}

		count := groupMatchCount(pattern, groups)
		total += count

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
