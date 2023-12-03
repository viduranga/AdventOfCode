import numpy as np

input_file = open('input.txt', 'r')


grid = np.full((50, 50, 50), 'o')

cubes = []

for line in input_file.readlines():
    x, y, z = [int(val) for val in line.strip().split(',')]
    grid[x, y, z] = '#'
    cubes.append((x, y, z))

reachable_queue = [(0, 0, 0)]

while reachable_queue:
    x, y, z = reachable_queue.pop()
    if 0 <= x < 50 and 0 <= y < 50 and 0 <= z < 50:
        if grid[x, y, z] == 'o':
            grid[x, y, z] = '.'
            reachable_queue.extend([(x - 1, y, z), (x + 1, y, z), (x, y - 1, z), (x, y + 1, z), (x, y, z - 1), (x, y, z + 1)])


side_count = 0

for x, y, z in cubes:
    for a_x, a_y, a_z in [(x-1, y, z), (x+1, y, z), (x, y-1, z), (x, y+1, z), (x, y, z-1), (x, y, z+1)]:
        if grid[a_x, a_y, a_z] == '.':
            side_count += 1

print(side_count)

