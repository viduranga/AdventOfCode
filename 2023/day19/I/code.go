package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"

	"github.com/viduranga/AdventOfCode/2023/util"
)

type (
	Catagory rune
	Equality rune
)

const (
	CAT_X Catagory = 'x'
	CAT_M Catagory = 'm'
	CAT_A Catagory = 'a'
	CAT_S Catagory = 's'
)

const (
	EQ_E Equality = '='
	EQ_L Equality = '<'
	EQ_G Equality = '>'
)

type Rule struct {
	catagory      Catagory
	equality      Equality
	value         int
	true_workflow string
}

type Workflow struct {
	name           string
	rules          []Rule
	false_workflow string
}

type Part struct {
	properties map[Catagory]int
}

func evalRule(rule Rule, part Part) bool {
	part_value := part.properties[rule.catagory]
	switch rule.equality {
	case EQ_E:
		return part_value == rule.value
	case EQ_L:
		return part_value < rule.value
	case EQ_G:
		return part_value > rule.value
	}
	return false
}

func findXXX(data [][]string) (int, error) {
	workflows := make(map[string]Workflow)

	parts := make([]Part, 0)

	re_workflow := regexp.MustCompile(`^(\w+){(.+)}$`)
	re_rule := regexp.MustCompile(`^(\w)([=<>])(\d+):(\w+)$`)
	for _, line := range data[0] {
		match := re_workflow.FindStringSubmatch(line)

		if len(match) == 0 {
			return -1, fmt.Errorf("invalid line: %s", line)
		}

		name := match[1]
		rules := make([]Rule, 0)

		rule_strs := strings.Split(match[2], ",")
		for i := 0; i < len(rule_strs)-1; i++ {
			rule_match := re_rule.FindStringSubmatch(rule_strs[i])
			catagory := Catagory(rule_match[1][0])
			equality := Equality(rule_match[2][0])
			value, _ := strconv.Atoi(rule_match[3])
			true_workflow := rule_match[4]
			rules = append(rules, Rule{catagory, equality, value, true_workflow})
		}

		false_workflow := rule_strs[len(rule_strs)-1]

		workflows[name] = Workflow{name, rules, false_workflow}
	}

	re_part := regexp.MustCompile(`^{(.+)}$`)
	for _, line := range data[1] {
		match := re_part.FindStringSubmatch(line)

		if len(match) == 0 {
			return -1, fmt.Errorf("invalid line: %s", line)
		}

		properties := make(map[Catagory]int)
		prop_strs := strings.Split(match[1], ",")
		for _, prop_str := range prop_strs {
			prop := strings.Split(prop_str, "=")
			properties[Catagory(prop[0][0])], _ = strconv.Atoi(prop[1])
		}

		parts = append(parts, Part{properties})
	}

	accepted := make([]Part, 0)

	for _, part := range parts {
		workflow_key := "in"
		for {
			if workflow_key == "A" {
				accepted = append(accepted, part)
				break
			} else if workflow_key == "R" {
				break
			}
			workflow := workflows[workflow_key]

			eval_true := false
			for _, rule := range workflow.rules {
				if evalRule(rule, part) {
					workflow_key = rule.true_workflow
					eval_true = true
					break
				}
			}

			if !eval_true {
				workflow_key = workflow.false_workflow
			}
		}

	}
	total := 0
	for _, part := range accepted {
		for _, prop := range part.properties {
			total += prop
		}
	}

	return total, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLineGroups(path)
	if err != nil {
		panic(err)
	}

	number, err := findXXX(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(number)
}
