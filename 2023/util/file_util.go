package util

import (
	"bufio"
	"os"
)

func FileToLines(path string) ([]string, error) {
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

func FileToLineGroups(path string) ([][]string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	defer file.Close()

	var groups [][]string
	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			groups = append(groups, lines)
			lines = []string{}
		} else {
			lines = append(lines, line)
		}
	}
	groups = append(groups, lines)
	return groups, scanner.Err()
}
