package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

func hash(data string) int {
	current := 0
	for _, c := range data {
		ascii := int(c)
		current += ascii
		current *= 17
		current %= 256
	}
	return current
}

func findXXX(data string) (int, error) {
	total := 0

	for _, str := range strings.Split(data, ",") {
		total += hash(str)
	}
	return total, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	number, err := findXXX(lines[0])
	if err != nil {
		panic(err)
	}

	fmt.Println(number)
}
