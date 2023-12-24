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
	EQ_L Equality = '<'
	EQ_G Equality = '>'
)

type Condition struct {
	catagory Catagory
	lt       int
	gt       int
}

func (c Condition) String() string {
	return fmt.Sprintf("%d < %c < %d", c.gt, c.catagory, c.lt)
}

const CAT_MAX = 4000

func (c Condition) invert() Condition {
	lt, gt := -1, -1
	if c.lt == CAT_MAX+1 {
		lt = c.gt + 1
		gt = 0
	} else if c.gt == 0 {
		lt = CAT_MAX + 1
		gt = c.lt - 1
	}

	return Condition{c.catagory, lt, gt}
}

type Rule struct {
	condition     Condition
	true_workflow string
}

func (r Rule) String() string {
	return fmt.Sprintf("[%s -> %s]", r.condition, r.true_workflow)
}

type Workflow struct {
	name           string
	rules          []Rule
	false_workflow string
}

func (w Workflow) String() string {
	return fmt.Sprintf("{%s | %s}", w.rules, w.false_workflow)
}

func findRules(workflows map[string]Workflow, current string, super_conditions []Condition) [][]Condition {
	workflow := workflows[current]

	conditions := make([][]Condition, 0)
	current_conditions := make([]Condition, 0)
	current_conditions = append(current_conditions, super_conditions...)

	for _, rule := range workflow.rules {
		condition_chain := make([]Condition, 0)
		condition_chain = append(condition_chain, current_conditions...)
		condition_chain = append(condition_chain, rule.condition)
		if rule.true_workflow == "A" {
			conditions = append(conditions, condition_chain)
		} else if rule.true_workflow != "R" {
			rules := findRules(workflows, rule.true_workflow, condition_chain)
			conditions = append(conditions, rules...)
		}
		current_conditions = append(current_conditions, rule.condition.invert())
	}

	if workflow.false_workflow == "A" {
		conditions = append(conditions, current_conditions)
	} else if workflow.false_workflow != "R" {
		rules := findRules(workflows, workflow.false_workflow, current_conditions)
		conditions = append(conditions, rules...)
	}
	return conditions
}

func simplifyConditions(condition_sets [][]Condition) []map[Catagory]Condition {
	simplitied_sets := make([]map[Catagory]Condition, 0)
	for _, conditions := range condition_sets {
		simplified := make(map[Catagory]Condition)
		for _, condition := range conditions {
			if _, ok := simplified[condition.catagory]; !ok {
				simplified[condition.catagory] = condition
			} else {
				simplified[condition.catagory] = Condition{condition.catagory, min(condition.lt, simplified[condition.catagory].lt), max(condition.gt, simplified[condition.catagory].gt)}
			}
		}

		// simplified_conditions := make([]Condition, 0)
		// for _, condition := range simplified {
		// 	simplified_conditions = append(simplified_conditions, condition)
		// }
		simplitied_sets = append(simplitied_sets, simplified)
	}
	return simplitied_sets
}

func findXXX(data [][]string) (int, error) {
	workflows := make(map[string]Workflow)

	re_workflow := regexp.MustCompile(`^(\w+){(.+)}$`)
	re_rule := regexp.MustCompile(`^(\w)([<>])(\d+):(\w+)$`)
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
			equality := rule_match[2]
			value, _ := strconv.Atoi(rule_match[3])
			true_workflow := rule_match[4]
			lt, gt := -1, -1
			if equality == "<" {
				lt = value
				gt = 0
			} else {
				lt = CAT_MAX + 1
				gt = value
			}
			rules = append(rules, Rule{Condition{catagory, lt, gt}, true_workflow})
		}

		false_workflow := rule_strs[len(rule_strs)-1]

		workflows[name] = Workflow{name, rules, false_workflow}
	}

	// fmt.Println(workflows)

	conditions := findRules(workflows, "in", make([]Condition, 0))

	// for _, c := range conditions {
	// 	fmt.Println(c)
	// }

	condition_maps := simplifyConditions(conditions)

	// fmt.Println("----")
	// for _, c := range conditions {
	// 	fmt.Println(c)
	// }
	total := 0
	for _, condition_map := range condition_maps {
		combinations := 1
		for _, catagory := range []Catagory{CAT_X, CAT_M, CAT_A, CAT_S} {
			if _, ok := condition_map[catagory]; !ok {
				combinations *= CAT_MAX
			} else {
				condition := condition_map[catagory]

				combinations *= (condition.lt - condition.gt - 1)
			}
		}
		total += combinations
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
