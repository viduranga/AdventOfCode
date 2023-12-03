package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
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

func findNumbersWithLiterals(data []string) ([]int, error) {
	literals := []string{"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}

	literalMap := make(map[string]int)
	for i, literal := range literals {
		literalMap[literal] = i + 1
	}

	digit_match := `(\d|` + strings.Join(literals, `|`) + `)`
	re := regexp.MustCompile(digit_match + `.*` + digit_match + `|` + digit_match)

	var result []int

	for _, line := range data {
		match := re.FindStringSubmatch(line)

		if len(match) == 0 {
			return nil, fmt.Errorf("no numbers found in %s", line)
		}
		first, second, single := match[1], match[2], match[3]

		if single != "" {
			first = single
			second = single
		}

		getDigit := func(literal string) (int, error) {
			digit, ok := literalMap[literal]
			if !ok {
				return strconv.Atoi(literal)
			}
			return digit, nil
		}

		firstDigit, err := getDigit(first)
		if err != nil {
			return nil, err
		}

		secondDigit, err := getDigit(second)
		if err != nil {
			return nil, err
		}

		result = append(result, firstDigit*10+secondDigit)
	}

	return result, nil
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

	numbers, err := findNumbersWithLiterals(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(sum(numbers))
}
