package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

type rangeMap struct {
	from string
	to   string

	from_ids []int
	ranges   []int
	to_ids   []int
}

func (r rangeMap) getMatching(from int) int {
	for i, from_id := range r.from_ids {
		if from_id <= from && from_id+r.ranges[i] >= from {
			return r.to_ids[i] + (from - from_id)
		}
	}
	return from
}

func findLocations(data [][]string) ([]int, error) {
	var result []int

	// first line in the first group is the seed list
	var seeds []int
	for _, seed_str := range strings.Split(data[0][0][7:], " ") {
		seed, err := strconv.Atoi(seed_str)
		if err != nil {
			return nil, err
		}
		seeds = append(seeds, seed)
	}

	range_maps := make(map[string]rangeMap)
	for _, group := range data[1:] {
		mapping_str := strings.Split(group[0], " ")[0]
		mapping := strings.Split(mapping_str, "-")

		var from_ids []int
		var ranges []int
		var to_ids []int

		for _, line := range group[1:] {
			split := strings.Split(line, " ")
			from_id, err := strconv.Atoi(split[1])
			to_id, err := strconv.Atoi(split[0])
			id_range, err := strconv.Atoi(split[2])
			if err != nil {
				return nil, err
			}
			from_ids = append(from_ids, from_id)
			ranges = append(ranges, id_range)
			to_ids = append(to_ids, to_id)
		}
		range_maps[mapping[0]] = rangeMap{
			from:     mapping[0],
			to:       mapping[2],
			from_ids: from_ids,
			ranges:   ranges,
			to_ids:   to_ids,
		}

	}

	for _, seed := range seeds {

		from := seed
		from_key := "seed"
		for from_key != "location" && from_key != "" {
			range_map := range_maps[from_key]
			from = range_map.getMatching(from)
			from_key = range_map.to
		}

		result = append(result, from)
	}
	return result, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLineGroups(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findLocations(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(util.ArrayMin(numbers))
}
