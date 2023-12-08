package main

import (
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

type Card struct {
	original string
	value    int64

	hand int

	winning int
}

func getHand(card string) int {
	var count map[string]int = make(map[string]int)

	for _, c := range card {
		count[string(c)]++
	}

	var max int = 0
	var second_max int = 0
	for _, v := range count {
		if v > max {
			max = v
		} else if v > second_max {
			second_max = v
		}
	}

	switch max {
	case 1:
		return 1
	case 2:
		if second_max == 1 {
			return 2
		} else {
			return 3
		}
	case 3:
		if second_max == 1 {
			return 4
		} else {
			return 5
		}
	case 4:
		return 6
	default:
		return 7
	}
}

func findRankValues(data []string) ([]int, error) {
	var result []int
	var cards []Card

	for _, line := range data {
		splits := strings.Split(line, " ")
		winning, _ := strconv.Atoi(splits[1])

		card := strings.Replace(splits[0], "A", "E", -1)
		card = strings.Replace(card, "K", "D", -1)
		card = strings.Replace(card, "Q", "C", -1)
		card = strings.Replace(card, "J", "B", -1)
		card = strings.Replace(card, "T", "A", -1)

		card_value, _ := strconv.ParseInt(card, 16, 64)

		cards = append(cards, Card{
			original: splits[0],
			value:    card_value,
			hand:     getHand(splits[0]),
			winning:  winning,
		})
	}

	sort.Slice(cards, func(i, j int) bool {
		if cards[i].hand == cards[j].hand {
			return cards[i].value < cards[j].value
		} else {
			return cards[i].hand < cards[j].hand
		}
	})

	for i, card := range cards {
		result = append(result, card.winning*(i+1))
	}

	return result, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	numbers, err := findRankValues(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(util.ArraySum(numbers))
}
