import numpy as np

input_file = open('input.txt', 'r')

grid = np.full((1200, 1200), '.')

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


grid[max_row+2:max_row+3, 0:1200] = '#'

sand_count = 0

pouring = True

while pouring:
    sand_r, sand_c = 0, 500
    while True:
        if grid[sand_r+1, sand_c] == '.':
            sand_r += 1
        elif grid[sand_r+1, sand_c-1] == '.':
            sand_r += 1
            sand_c -= 1
        elif grid[sand_r+1, sand_c+1] == '.':
            sand_r += 1
            sand_c += 1
        else:
            grid[sand_r, sand_c] = 'O'
            sand_count += 1

            if sand_r == 0 and sand_c == 500:
                pouring = False

            break

print(sand_count)