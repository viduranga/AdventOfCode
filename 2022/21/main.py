from dataclasses import dataclass
from typing import List, Tuple

input_file = open('input.txt', 'r')

lines = iter(input_file.readlines())


@dataclass
class Item:
    worry_level: int


@dataclass
class Monkey:
    id: int
    items: List[Item]
    operation: str

    throw_division: int
    throw_to: Tuple
    inspected_count: int = 0

    def new_worry_level(self, item):
        old = item.worry_level
        val = eval(self.operation)
        return val

    def throw_item_to(self, item):
        if item.worry_level % self.throw_division == 0:
            return self.throw_to[0]
        else:
            return self.throw_to[1]


monkeys = []

while monkey_data := next(lines, None):
    monkey_id = int(monkey_data[7])
    item_list = [Item(worry_level=int(worry)) for worry in next(lines)[18:].strip().split(',')]
    operation = next(lines)[19:].strip()
    throw_division = int(next(lines)[21:])
    throw_to_true = int(next(lines)[29:])
    throw_to_false = int(next(lines)[30:])

    monkeys.append(
        Monkey(
            id=monkey_id,
            items=item_list,
            operation=operation,
            throw_division=throw_division,
            throw_to=(throw_to_true, throw_to_false)
        )
    )

    next(lines, None)

rounds = 20

for round in range(rounds):
    for monkey in monkeys:
        monkey.inspected_count += len(monkey.items)
        for item in monkey.items:
            new_worry = monkey.new_worry_level(item)
            new_worry = new_worry // 3
            item.worry_level = new_worry
            throw_to = monkey.throw_item_to(item)
            monkeys[throw_to].items.append(item)

        monkey.items = []

inspections = sorted([monkey.inspected_count for monkey in monkeys])

print(inspections[-1]*inspections[-2])