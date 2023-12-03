from dataclasses import dataclass
from enum import Enum

content_file = open('input.txt', 'r')


class Ins(Enum):
    NOOP = 0
    ADDX = 1


instructions = []

for line in content_file.readlines():
    line = line.strip()
    if line[:4] == 'addx':
        instructions.extend([(Ins.NOOP,), (Ins.ADDX, int(line[5:]))])
    else:
        instructions.append((Ins.NOOP,))


cycle = 0
register = 1

signal_strength = 0
for instruction in instructions:
    cycle += 1

    if cycle in [20, 60, 100, 140, 180, 220]:
        print(cycle, register)
        signal_strength += cycle*register

    if instruction[0] == Ins.ADDX:
        register += instruction[1]

print(signal_strength)