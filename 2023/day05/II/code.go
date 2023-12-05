package main

import (
	"fmt"
	"math"
	"os"
	"sort"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

type Range struct {
	from   int64
	to     int64
	offset int64
}

type RangeMap struct {
	from string
	to   string

	ranges []Range
}

func (r RangeMap) getMatching(match Range) []Range {
	var result []Range
	for _, value_range := range r.ranges {

		offset := value_range.offset
		if value_range.from <= match.from+match.offset && value_range.to >= match.to+match.offset {
			result = append(result, Range{from: (match.from + match.offset), to: (match.to + match.offset), offset: offset})
		} else if value_range.from <= match.from+match.offset && value_range.to >= match.from+match.offset {
			result = append(result, Range{from: (match.from + match.offset), to: (value_range.to), offset: offset})
		} else if value_range.from <= match.to+match.offset && value_range.to >= match.to+match.offset {
			result = append(result, Range{from: (value_range.from), to: (match.to + match.offset), offset: offset})
		} else if value_range.from >= match.from+match.offset && value_range.to <= match.to+match.offset {
			result = append(result, Range{from: (value_range.from), to: (value_range.to), offset: offset})
		}
	}

	if len(result) == 0 {
		return []Range{match}
	}

	sort.Slice(result, func(i, j int) bool {
		return result[i].from < result[j].from
	})

	// go through the list and add gaps
	var gaps []Range
	if result[0].from > match.from+match.offset {
		gaps = append(gaps, Range{from: match.from + match.offset, to: result[0].from, offset: 0})
	}
	if result[len(result)-1].to < match.to+match.offset {
		gaps = append(gaps, Range{from: result[len(result)-1].to, to: match.to + match.offset, offset: 0})
	}

	for i := 0; i < len(result)-1; i++ {
		if result[i].to < result[i+1].from {
			gaps = append(gaps, Range{from: result[i].to, to: result[i+1].from, offset: 0})
		}
	}

	return append(result, gaps...)
}

func getMatchingRanges(from string, match Range, range_maps *map[string]RangeMap) []Range {
	var result []Range
	if from == "location" {
		return []Range{match}
	} else {
		range_map := (*range_maps)[from]
		matchings := range_map.getMatching(match)

		for _, matching := range matchings {
			result = append(result, getMatchingRanges(range_map.to, matching, range_maps)...)
		}
	}
	return result
}

func findClosestLocation(data [][]string) (int64, error) {
	// first line in the first group is the seed list
	var seed_ranges []Range
	seed_data := strings.Split(data[0][0][7:], " ")

	for i := 0; i < len(seed_data); i += 2 {
		seed, _ := strconv.ParseInt(seed_data[i], 10, 64)
		seed_range, _ := strconv.ParseInt(seed_data[i+1], 10, 64)
		seed_ranges = append(seed_ranges, Range{from: seed, to: seed + seed_range, offset: 0})
	}

	range_maps := make(map[string]RangeMap)
	for _, group := range data[1:] {
		mapping_str := strings.Split(group[0], " ")[0]
		mapping := strings.Split(mapping_str, "-")

		var ranges []Range

		for _, line := range group[1:] {
			split := strings.Split(line, " ")
			destination_id, err := strconv.ParseInt(split[0], 10, 64)
			source_id, err := strconv.ParseInt(split[1], 10, 64)
			id_range, err := strconv.ParseInt(split[2], 10, 64)
			if err != nil {
				return -1, err
			}
			ranges = append(ranges, Range{from: source_id, to: source_id + id_range, offset: destination_id - source_id})
		}
		range_maps[mapping[0]] = RangeMap{
			from:   mapping[0],
			to:     mapping[2],
			ranges: ranges,
		}
	}

	var location_ranges []Range
	for _, seed_range := range seed_ranges {
		location_ranges = append(location_ranges, getMatchingRanges("seed", seed_range, &range_maps)...)
	}

	var min_location int64 = math.MaxInt64
	for _, location_range := range location_ranges {
		if location_range.from+location_range.offset < min_location {
			min_location = location_range.from + location_range.offset
		}
	}

	return min_location, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLineGroups(path)
	if err != nil {
		panic(err)
	}

	number, err := findClosestLocation(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(number)
}
