package util

import (
	"bufio"
	"os"
	"strconv"
	"strings"
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

func FileToBitGroups(path string, ones string, zeros string) ([][]uint64, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	defer file.Close()

	var groups [][]uint64
	var lines []uint64
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			groups = append(groups, lines)
			lines = []uint64{}
		} else {
			oned := strings.ReplaceAll(line, ones, "1")
			zerod := strings.ReplaceAll(oned, zeros, "0")
			val, _ := strconv.ParseUint(zerod, 2, 64)
			lines = append(lines, val)
		}
	}
	groups = append(groups, lines)
	return groups, scanner.Err()
}
