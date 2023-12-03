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

func findPossibleGames(data []string, max_count map[string]int) ([]int, error) {
	game_re := regexp.MustCompile(`Game (\d+)`)

	var max_count_re map[string]*regexp.Regexp = make(map[string]*regexp.Regexp)

	for color := range max_count {
		max_count_re[color] = regexp.MustCompile(fmt.Sprintf(`(\d+) %s`, color))
	}

	var result []int

	for _, line := range data {
		splits := strings.Split(line, ": ")

		game_match := game_re.FindStringSubmatch(splits[0])

		game, err := strconv.Atoi(game_match[1])
		if err != nil {
			return nil, err
		}

		rounds := strings.Split(splits[1], ";")

		var max_found bool = false
		for _, round := range rounds {
			for color, max_count := range max_count {
				count_match := max_count_re[color].FindStringSubmatch(round)
				if len(count_match) < 2 {
					continue
				}

				count, err := strconv.Atoi(count_match[1])
				if err != nil {
					return nil, err
				}

				if count > max_count {

					max_found = true
					break
				}
			}
		}

		if !max_found {
			result = append(result, game)
		}
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

	numbers, err := findPossibleGames(lines, map[string]int{"red": 12, "green": 13, "blue": 14})
	if err != nil {
		panic(err)
	}

	fmt.Println(sum(numbers))
}
