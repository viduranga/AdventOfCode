import re
from dataclasses import dataclass
from typing import List

input_file = open('input.txt', 'r')


@dataclass
class Valve:
    flow_rate: int
    adjacent: set[str]


root = None
valves = {}

non_stuck_valves_count = 0

for line in input_file.readlines():
    match = re.match(r'Valve (\w\w) has flow rate=(\d+); tunnel(s*) lead(s*) to valve(s*) (.+)', line.strip())

    valve_name = match.group(1)
    valve = Valve(
        flow_rate=int(match.group(2)),
        adjacent=set(match.group(6).split(', '))
    )

    valves[valve_name] = valve

    if valve.flow_rate > 0:
        non_stuck_valves_count += 1
    if root is None:
        root = valve_name


@dataclass
class VisitEntry:
    valve_id: str
    remaining: int
    release: int
    previous_id: str
    open: set[str]


visit_queue = [VisitEntry(root, 30, 0, None, set())]
max_release = 0

max_visit_queue = 0
i = 0
while visit_queue:
    i += 1
    max_visit_queue = max(max_visit_queue, len(visit_queue))
    current = visit_queue.pop()

    max_release = max(max_release, current.release)
    valve = valves[current.valve_id]

    if len(current.open) == non_stuck_valves_count:
        continue
    if current.remaining > 2 and current.valve_id not in current.open and valve.flow_rate > 0:
        new_release = current.release + valve.flow_rate*(current.remaining-1)
        visit_queue.extend([VisitEntry(next_id, current.remaining-2, new_release, current.valve_id, current.open.union({current.valve_id})) for next_id in valve.adjacent])
    if current.remaining > 1:
        visit_queue.extend([VisitEntry(next_id, current.remaining-1, current.release, current.valve_id, current.open) for next_id in valve.adjacent if next_id != current.previous_id])


print(max_release)
print(max_visit_queue)
print(i)