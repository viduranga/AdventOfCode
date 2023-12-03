import re

content_file = open('input.txt', 'r')

lines = content_file.readlines()

stack_count = (len(lines[0]) + 1) // 4
stacks = ["" for _ in range(stack_count)]

line_id = 0
while lines[line_id][1] != '1':
    line = lines[line_id]
    line_id += 1

    for i in range(1, len(line), 4):
        if line[i] != ' ':
            stacks[(i-1)//4] += line[i]

line_id += 2

for i in range(line_id, len(lines)):
    line = lines[i]
    match = re.match(r'move (\d+) from (\d+) to (\d+)', line.strip())
    count = int(match.group(1))
    from_id = int(match.group(2))-1
    to_id = int(match.group(3))-1

    data = stacks[from_id][:count]
    stacks[from_id] = stacks[from_id][count:]
    stacks[to_id] = data + stacks[to_id]


out = ''

for stack in stacks:
    if len(stack):
        out += stack[0]

print(out)
