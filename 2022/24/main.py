import heapq
import math
from dataclasses import dataclass

input_file = open('test.txt', 'r')


def char_id(char):
    return ord(char) - ord('a')


@dataclass
class Vertex:
    x: int
    y: int
    height: int
    visited: bool = False
    distance: int = math.inf
    steps: int = math.inf

    def __lt__(self, other):
        return self.distance < other.distance

    def __le__(self, other):
        return self.distance <= other.distance


grid = []

start = None
destinations = []

unvisited_queue = []

for i, line in enumerate(input_file.readlines()):

    raw = []

    for j, char in enumerate(line.strip()):
        vertex = Vertex(
            x=j,
            y=i,
            height=char_id(char)
        )
        if char == 'S':
            destinations.append(vertex)
            vertex.height = char_id('a')
        elif char == 'E':
            start = vertex
            vertex.height = char_id('z')
            vertex.distance = 0
            vertex.steps = 0
        elif char == 'a':
            destinations.append(vertex)

        raw.append(vertex)

        unvisited_queue.append((vertex.distance, vertex))

    grid.append(raw)

heapq.heapify(unvisited_queue)

while len(unvisited_queue):
    uv = heapq.heappop(unvisited_queue)
    current = uv[1]
    current.visited = True

    for i, j in [(current.y, current.x-1),
                 (current.y, current.x+1),
                 (current.y-1, current.x),
                 (current.y+1, current.x)]:
        if i < 0 or i >= len(grid) or j < 0 or j >= len(grid[0]):
            continue
        next = grid[i][j]

        if next.visited:
            continue

        if current.height - next.height > 1:
            continue

        new_dist = current.distance + 1

        if new_dist < next.distance:
            next.distance = new_dist
            next.steps = current.steps + 1

        unvisited_queue = [(v.distance, v) for raw in grid for v in raw if not v.visited]
        heapq.heapify(unvisited_queue)


steps = []
for destination in destinations:

    if destination.steps != math.inf:
        steps.append(destination.steps)

print(min(steps))
