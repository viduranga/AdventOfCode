package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/viduranga/AdventOfCode/2023/util"
)

type Coord struct {
	x, y int
}

type Line struct {
	direction rune
	steps     int
}

func (c Coord) String() string {
	return fmt.Sprintf("(%d, %d)", c.x, c.y)
}

func findXXX(data []string) (int, error) {
	path := make([]Coord, 0)
	current := Coord{0, 0}

	lines := make([]Line, 0)
	re := regexp.MustCompile(`^\w \d+ \(#(\w{5})(\d)\)$`)

	for _, line := range data {
		match := re.FindStringSubmatch(line)

		if len(match) == 0 {
			return -1, fmt.Errorf("invalid line: %s", line)
		}
		steps, _ := strconv.ParseInt(match[1], 16, 32)
		direction := ' '
		switch match[2] {
		case "0":
			direction = 'R'
		case "1":
			direction = 'D'
		case "2":
			direction = 'L'
		case "3":
			direction = 'U'
		}
		lines = append(lines, Line{direction, int(steps)})
	}

	shadow := 0

	for i, line := range lines {
		next := lines[(i+1)%len(lines)]

		coord := Coord{current.x, current.y}
		switch line.direction {
		case 'L':
			coord.x -= line.steps

			if next.direction == 'D' {
				shadow += (line.steps - 1)
			} else if next.direction == 'U' {
				shadow += (line.steps)
			}
		case 'R':
			coord.x += line.steps

			if next.direction == 'D' {
				shadow += (line.steps)
			} else if next.direction == 'U' {
				shadow += (line.steps + 1)
			}
		case 'U':
			coord.y -= line.steps

			if next.direction == 'L' {
				shadow += (line.steps)
			} else if next.direction == 'R' {
				shadow += (line.steps - 1)
			}
		case 'D':
			coord.y += line.steps

			if next.direction == 'L' {
				shadow += (line.steps + 1)
			} else if next.direction == 'R' {
				shadow += (line.steps)
			}
		}
		path = append(path, coord)
		current = coord

	}

	shadow = (shadow + 2) / 2

	current = path[0]

	// Shoelace formula
	s_1, s_2 := 0, 0

	for i := 0; i < len(path)-1; i++ {
		s_1 += path[i].x * path[i+1].y
		s_2 += path[i].y * path[i+1].x
	}

	s_1 += path[len(path)-1].x * path[0].y
	s_2 += path[len(path)-1].y * path[0].x

	inside_area := (s_1 - s_2) / 2

	total_area := inside_area + shadow

	return total_area, nil
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
