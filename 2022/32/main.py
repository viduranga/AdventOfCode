import re
from dataclasses import dataclass

input_file = open('input.txt', 'r')


@dataclass
class Valve:
    flow_rate: int
    adjacent: dict[str, int]

root = None
valves = {}

non_stuck_valves = []

for line in input_file.readlines():
    match = re.match(r'Valve (\w\w) has flow rate=(\d+); tunnel(s*) lead(s*) to valve(s*) (.+)', line.strip())

    valve_name = match.group(1)
    flow_rate = int(match.group(2)),
    adjacent = set(match.group(6).split(', '))
    valve = Valve(
        flow_rate=int(match.group(2)),
        adjacent={to: 1 for to in match.group(6).split(', ')}
    )

    valves[valve_name] = valve
    if valve_name == 'AA':
        root = valve_name

    if valve.flow_rate > 0:
        non_stuck_valves.append(valve)


non_stuck_count = len(non_stuck_valves)

for valve_name in list(valves.keys()):
    valve = valves[valve_name]
    if len(valve.adjacent) == 2 and valve.flow_rate == 0 and valve_name != 'AA':
        adjacent_keys = list(valve.adjacent.keys())
        merged_distance = valves[valve_name].adjacent[adjacent_keys[0]] + valves[valve_name].adjacent[adjacent_keys[1]]
        valves[adjacent_keys[0]].adjacent[adjacent_keys[1]] = merged_distance
        valves[adjacent_keys[1]].adjacent[adjacent_keys[0]] = merged_distance
        del valves[valve_name]
        del valves[adjacent_keys[0]].adjacent[valve_name]
        del valves[adjacent_keys[1]].adjacent[valve_name]


def get_max_release(valve_id, opened, minute, previous_id):
    if minute <= 1:  # if we're at the last minute, it's too late to do anything effective
        return 0  # So the current release is the maximum possible on this path

    valve = valves[valve_id]  # Get the valve object

    path_releases = [0]

    if valve_id not in opened and valve.flow_rate > 0:  # If this valve is not opened yet

        # Open the current valve
        release = (minute - 1) * valve.flow_rate  # Add this valve's flow
        # release to the existing
        # value
        new_opened = opened | {valve_id}  # add the current valve id to the opened set

        if (len(new_opened) == non_stuck_count + 1  # If we have opened all the valves, no point moving forward
                or minute <= 3  # There's no more time for us to go and do anything on other valve
        ):
            return release  # So the current release is the maximum possible on this path

        # Recursively get the new flow releases for the adjacent paths assuming we turned the
        # current valve ON
        # We reduce the time by 2 minutes because we spend 1 min opening and 1 min traveling
        path_releases.extend(release + get_max_release(next_valve,
                                                       new_opened,
                                                       minute - 1 - next_distance,
                                                       valve_id)
                             for next_valve, next_distance in valve.adjacent.items())

    if minute >= 3:  # Go to other valve only if we have enough time to open it and move on
        # Recursively get the new flow releases for the following paths assuming we didn't turn the
        # current valve ON
        # We reduce the time by 1 minute because we spend 1 min traveling
        path_releases.extend(get_max_release(next_valve,
                                             opened,
                                             minute - next_distance,
                                             valve_id)
                             for next_valve, next_distance in valve.adjacent.items() if next_valve != previous_id)

    return max(path_releases)


max_release = get_max_release(root, {"AA"}, 30, None)

print(max_release)
