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

crt = ''

for instruction in instructions:

    if cycle % 40 in (register-1, register, register+1):
        crt += '#'
    else:
        crt += '.'

    cycle += 1

    if instruction[0] == Ins.ADDX:
        register += instruction[1]

for i in range(len(crt)//40):
    print(crt[i*40:(i+1)*40])