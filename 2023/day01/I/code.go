package aoc_2023_1

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
)

func readFile(path string) ([]string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	return lines, scanner.Err()
}

func findNumbers(data []string) ([]int, error) {
	re := regexp.MustCompile(`^\D*(\d).*?(\d?)\D*$`)

	var result []int

	for _, line := range data {
		match := re.FindStringSubmatch(line)

		if len(match) == 0 {
			return nil, fmt.Errorf("no numbers found in %s", line)
		}
		first, second := match[1], match[2]

		if second == "" {
			second = first
		}
		digit, err := strconv.Atoi(first + second)
		if err != nil {
			return nil, err
		}

		result = append(result, digit)
	}

	return result, nil
}

// func sum(numbers []int) int {
// 	var result int
// 	for _, number := range numbers {
// 		result += number
// 	}
// 	return result
// }

// func main() {
// 	path := os.Args[1]
// 	lines, err := readFile(path)
// 	if err != nil {
// 		panic(err)
// 	}
//
// 	numbers, err := findNumbers(lines)
// 	if err != nil {
// 		panic(err)
// 	}
//
// 	fmt.Println(sum(numbers))
// }
