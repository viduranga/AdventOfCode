from dataclasses import dataclass, field
from typing import Any

content_file = open('input.txt', 'r')

grid = []

for line in content_file.readlines():
    grid.append([int(height) for height in line.strip()])


def visible(l, tree):
    if not l:
        return True
    else:
        return max(l) < tree


column_grid = list(zip(*grid))

visible_count = 0
for j in range(len(grid)):
    row = grid[j]
    for i in range(len(row)):
        tree = row[i]
        if visible(row[:i], tree) or visible(row[i+1:], tree) or visible(column_grid[i][:j], tree) or visible(column_grid[i][j+1:], tree):
            visible_count += 1

print(visible_count)
