package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
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

type Lense struct {
	label string
	power int
}

func findXXX(data string) (int, error) {
	total := 0

	boxes := make(map[int][]Lense)

	step_re := regexp.MustCompile(`^(\w+)(?:(-|=)(\d*))$`)
	for _, str := range strings.Split(data, ",") {
		match := step_re.FindStringSubmatch(str)
		box_id := hash(match[1])

		switch match[2] {
		case "-":
			lenses := boxes[box_id]
			found := false
			for i, lense := range lenses {
				if found {
					lenses[i-1] = lenses[i]
				}
				if lense.label == match[1] {
					found = true
				}
			}
			if found {
				boxes[box_id] = lenses[:len(lenses)-1]
			}

		case "=":
			power, _ := strconv.Atoi(match[3])
			new_lense := Lense{label: match[1], power: power}

			lenses := boxes[box_id]
			found := false
			for i, lense := range lenses {
				if lense.label == match[1] {
					found = true
					lenses[i] = new_lense
					break
				}
			}
			if !found {
				boxes[box_id] = append(boxes[box_id], new_lense)
			} else {
				boxes[box_id] = lenses
			}
		}
	}
	for box, lenses := range boxes {
		for i, lense := range lenses {
			focus_power := (box + 1) * (i + 1) * lense.power
			total += focus_power
		}
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
