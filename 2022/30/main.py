import itertools
import re
from dataclasses import dataclass
from typing import Tuple

input_file = open('input.txt', 'r')


@dataclass
class Coordinates:
    x: int
    y: int

    def manhattan_distance(self, other):
        return abs(self.x-other.x) + abs(self.y-other.y)


@dataclass
class Line:
    start: Coordinates
    end: Coordinates

    m: int
    c: float

    @staticmethod
    def ccw(A, B, C):
        return (C.y - A.y) * (B.x - A.x) > (B.y - A.y) * (C.x - A.x)

    def intersects(self, other):
        return self.ccw(self.start, other.start, other.end) != self.ccw(self.end, other.start, other.end) and self.ccw(self.start, self.end, other.start) != self.ccw(self.start, self.end, other.end)


@dataclass
class Sensor:
    position: Coordinates
    up_left: Line
    up_right: Line
    down_left: Line
    down_right: Line

sensors = []

for line in input_file.readlines():

    match = re.match(r'Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)', line.strip())
    sensor_position = Coordinates(
        x=int(match.group(1)),
        y=int(match.group(2))
    )
    beacon_position = Coordinates(
        x=int(match.group(3)),
        y=int(match.group(4))
    )

    manhattan_distance = sensor_position.manhattan_distance(beacon_position)
    up = Coordinates(x=sensor_position.x, y=sensor_position.y - manhattan_distance)
    down = Coordinates(x=sensor_position.x, y=sensor_position.y + manhattan_distance)
    left = Coordinates(x=sensor_position.x - manhattan_distance, y=sensor_position.y)
    right = Coordinates(x=sensor_position.x + manhattan_distance, y=sensor_position.y)
    sensor = Sensor(
        position=sensor_position,
        up_left=Line(up, left, m=-1, c=up.y+up.x),
        up_right=Line(up, right, m=1, c=up.y-up.x),
        down_left=Line(down, left, m=1, c=down.y-down.x),
        down_right=Line(down, right, m=-1, c=down.y+down.x),
    )

    sensors.append(sensor)


def line_check(pos_lines: Tuple[Line, Line], neg_lines: Tuple[Line, Line]):

    if (abs(neg_lines[0].c - neg_lines[1].c) == 2 and
            abs(pos_lines[0].c - pos_lines[1].c) == 2 and
            neg_lines[0].intersects(pos_lines[0]) and
            neg_lines[0].intersects(pos_lines[1]) and
            neg_lines[1].intersects(pos_lines[0]) and
            neg_lines[1].intersects(pos_lines[1])
    ):
        intersect_1_x = (neg_lines[0].c - pos_lines[0].c)/2
        intersect_1_y = intersect_1_x + pos_lines[0].c

        intersect_2_x = (neg_lines[1].c - pos_lines[1].c)/2
        intersect_2_y = intersect_1_x + pos_lines[1].c

        return Coordinates(x=int((intersect_1_x+intersect_2_x)/2), y=int((intersect_1_y+intersect_2_y)//2))

pos_candidates = []
neg_candidates = []

for sensor_1, sensor_2 in itertools.combinations(sensors, 2):
    if sensor_2.up_left.c - sensor_1.down_right.c == 2:
        neg_candidates.append((sensor_1.down_right, sensor_2.up_left))
    elif sensor_1.up_left.c - sensor_2.down_right.c == 2:
        neg_candidates.append((sensor_2.down_right, sensor_1.up_left))
    elif sensor_2.up_right.c - sensor_1.down_left.c == 2:
        pos_candidates.append((sensor_1.down_left, sensor_2.up_right))
    elif sensor_1.up_right.c - sensor_2.down_left.c == 2:
        pos_candidates.append((sensor_2.down_left, sensor_1.up_right))


for pos_lines in pos_candidates:
    for neg_lines in neg_candidates:
        loc = line_check(pos_lines, neg_lines)
        if loc:
            freq = loc.x*4000000+loc.y
            print(loc)
            print(freq)
            break
