content_file = open('input.txt', 'r')

grid = []

for line in content_file.readlines():
    grid.append([int(height) for height in line.strip()])


def visible_trees(l, tree):
    tall_idx = [i for i, h in enumerate(l) if h >= tree]
    if tall_idx:
        return tall_idx[0]+1
    else:
        return len(l)


column_grid = list(zip(*grid))

max_score = 0
for j in range(len(grid)):
    row = grid[j]
    for i in range(len(row)):
        tree = row[i]
        score = visible_trees(row[:i][::-1], tree) * visible_trees(row[i+1:], tree) * visible_trees(column_grid[i][:j][::-1], tree) * visible_trees(column_grid[i][j+1:], tree)
        max_score = max(max_score, score)


print(max_score)
