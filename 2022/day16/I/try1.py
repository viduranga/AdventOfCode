import re
from dataclasses import dataclass
from functools import cache

input_file = open('test.txt', 'r')


@dataclass
class Valve:
    flow_rate: int
    adjacent: set[str]


root = None
valves = {}

non_stuck_count = 0

for line in input_file.readlines():
    match = re.match(r'Valve (\w\w) has flow rate=(\d+); tunnel(s*) lead(s*) to valve(s*) (.+)', line.strip())

    valve_name = match.group(1)
    valve = Valve(
        flow_rate=int(match.group(2)),
        adjacent=set(match.group(6).split(', '))
    )

    valves[valve_name] = valve
    if valve.flow_rate > 0:
        non_stuck_count += 1

    if valve_name == 'AA':
        root = valve_name

@cache
def get_max_release(valve_id, opened, current_release, minute, previous_id):
    # print(opened)
    if minute <= 1:  # if we're at the last minute, it's too late to do anything effective
        return current_release  # So the current release is the maximum possible on this path

    valve = valves[valve_id]  # Get the valve object

    path_releases = [current_release]

    if (valve_id not in opened  # If this valve is not opened yet
            and valve.flow_rate > 0  # If this valve is not stuck
    ):
        # Open the current valve
        new_release = current_release + (minute - 1) * valve.flow_rate  # Add this valve's flow
                                                                        # release to the existing
                                                                        # value
        new_opened = opened + f"{valve_id},"  # add the current valve id to the opened set

        if minute <= 3:  # There's no more time for us to go and do anything on other valve
        # ):
            return new_release  # So the current release is the maximum possible on this path

        # Recursively get the new flow releases for the adjacent paths assuming we turned the
        # current valve ON
        # We reduce the time by 2 minutes because we spend 1 min opening and 1 min traveling
        path_releases.extend(get_max_release(next_valve, new_opened, new_release, minute - 2, valve_id)
                             for next_valve in valve.adjacent)

    if minute >= 3:  # Go to other valve only if we have enough time to open it and move on
        # Recursively get the new flow releases for the following paths assuming we didn't turn the
        # current valve ON
        # We reduce the time by 1 minute because we spend 1 min traveling
        path_releases.extend(get_max_release(next_valve, opened, current_release, minute - 1, valve_id)
                             for next_valve in valve.adjacent.difference({previous_id}))

    return max(path_releases)


max_release = get_max_release(root, "", 0, 30, "")

print(max_release)
