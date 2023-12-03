package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
	// "strings"
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

func nearGears(symbol_re *regexp.Regexp, data []string, start int, end int, row int) []int {
	if start < 0 {
		start = 0
	}
	if end > len(data[row]) {
		end = len(data[row])
	}

	line_length := len(data[0])

	var near_gears []int
	for i := row - 1; i <= row+1; i++ {
		if i < 0 || i >= line_length {
			continue
		}
		match := symbol_re.FindAllStringIndex(data[i][start:end], -1)

		if len(match) > 0 {
			for _, m := range match {
				gear_id := m[0] + start + (line_length * i)
				near_gears = append(near_gears, gear_id)
			}
		}
	}
	return near_gears
}

func findGearRatios(data []string) ([]int, error) {
	number_re := regexp.MustCompile(`(\d+)`)

	gear_re := regexp.MustCompile(`\*`)

	near_gear_map := make(map[int][]int)

	for row, line := range data {

		number_match := number_re.FindAllStringIndex(line, -1)

		for _, match := range number_match {
			number, err := strconv.Atoi(line[match[0]:match[1]])
			if err != nil {
				return nil, err
			}

			near_gears := nearGears(gear_re, data, match[0]-1, match[1]+1, row)

			for _, near_gear := range near_gears {
				near_gear_map[near_gear] = append(near_gear_map[near_gear], number)
			}
		}
	}

	var gear_ratios []int

	for _, near_gears := range near_gear_map {
		if len(near_gears) == 2 {
			gear_ratios = append(gear_ratios, near_gears[0]*near_gears[1])
		}
	}

	return gear_ratios, nil
}

func sum(numbers []int) int {
	var result int
	for _, number := range numbers {
		result += number
	}
	return result
}

func main() {
	path := os.Args[1]
	lines, err := readFile(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findGearRatios(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(sum(numbers))
}
