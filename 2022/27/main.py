import numpy as np

input_file = open('input.txt', 'r')

grid = np.full((600, 600), '.')

max_row = 0

for line in input_file.readlines():
    prev_column, prev_row = None, None
    for pair in line.split(' -> '):
        column, row = [int(val) for val in pair.split(',')]
        if prev_column is not None:
            start_c = min(prev_column, column)
            end_c = max(prev_column, column)
            start_r = min(prev_row, row)
            end_r = max(prev_row, row)
            grid[start_r:end_r+1, start_c:end_c+1] = '#'

        prev_column, prev_row = column, row
        max_row = max(max_row, row)

sand_count = 0

pouring = True

while pouring:
    sand_r, sand_c = 0, 500
    while True:
        if sand_r == 599 or sand_r > max_row:
            pouring = False
            break

        if grid[sand_r+1, sand_c] == '.':
            sand_r += 1
        elif sand_c > 0 and grid[sand_r+1, sand_c-1] == '.':
            sand_r += 1
            sand_c -= 1
        elif sand_c < 599 and grid[sand_r+1, sand_c+1] == '.':
            sand_r += 1
            sand_c += 1
        else:
            grid[sand_r, sand_c] = 'O'
            sand_count += 1
            break


print(sand_count)