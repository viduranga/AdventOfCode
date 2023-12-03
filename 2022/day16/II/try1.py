import math
import re
from dataclasses import dataclass
from itertools import permutations
import time

input_file = open('input.txt', 'r')


@dataclass
class Valve:
    id: str
    flow_rate: int
    adjacent: dict[str, int]


root = None
valves: dict = {}

non_stuck_valves = []

for line in input_file.readlines():
    match = re.match(r'Valve (\w\w) has flow rate=(\d+); tunnel(s*) lead(s*) to valve(s*) (.+)', line.strip())

    valve_name = match.group(1)
    flow_rate = int(match.group(2)),
    adjacent = set(match.group(6).split(', '))
    _valve = Valve(
        id=valve_name,
        flow_rate=int(match.group(2)),
        adjacent={to: 1 for to in match.group(6).split(', ')}
    )

    valves[valve_name] = _valve
    if valve_name == 'AA':
        root = _valve

    if _valve.flow_rate > 0:
        non_stuck_valves.append(_valve)

non_stuck_count = len(non_stuck_valves)

# Simplify the graph
for valve_name in list(valves.keys()):
    _valve = valves[valve_name]
    if len(_valve.adjacent) == 2 and _valve.flow_rate == 0 and valve_name != 'AA':
        adjacent_keys = list(_valve.adjacent.keys())
        merged_distance = valves[valve_name].adjacent[adjacent_keys[0]] + valves[valve_name].adjacent[adjacent_keys[1]]
        valves[adjacent_keys[0]].adjacent[adjacent_keys[1]] = merged_distance
        valves[adjacent_keys[1]].adjacent[adjacent_keys[0]] = merged_distance
        del valves[valve_name]
        del valves[adjacent_keys[0]].adjacent[valve_name]
        del valves[adjacent_keys[1]].adjacent[valve_name]


dist: dict = {}

for i in valves.keys():
    for j in valves.keys():
        dist[i, j] = math.inf

for valve in valves.values():
    for adjacent, distant in valve.adjacent.items():
        dist[valve.id, adjacent] = distant
        dist[adjacent, valve.id] = distant
    dist[valve.id, valve.id] = 0

for k in valves.keys():
    for i in valves.keys():
        for j in valves.keys():
            dist[i, j] = min(dist[i, j], dist[i, k] + dist[k, j])


available_time = 29

max_release = 0
max_order = None

start = time.process_time()

p = 0
for open_order in permutations(non_stuck_valves):
    p += 1
    if dist[root.id, open_order[0].id] != 1:
        continue
    local_available_time = available_time
    release = 0
    i = 0
    while local_available_time > 0:
        current_valve: Valve = open_order[i]
        local_available_time -= 1  # time to open the valve
        release += local_available_time * current_valve.flow_rate

        i += 1

        if i >= non_stuck_count:
            break

        next_valve: Valve = open_order[i]

        local_available_time -= dist[current_valve.id, next_valve.id]

    max_release = max(max_release, release)


print(len(non_stuck_valves))
print(p)
print(max_release)

# print(f"{time.process_time() - start}s")
