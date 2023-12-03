import re
from dataclasses import dataclass

input_file = open('input.txt', 'r')

scan_row = 2000000


@dataclass
class Coordinates:
    x: int
    y: int

    def manhattan_distance(self, other):
        return abs(self.x-other.x) + abs(self.y-other.y)


@dataclass
class Sensor:
    position: Coordinates
    closest_beacon: Coordinates

    beacon_distance: int = 0

sensors = []

for line in input_file.readlines():

    match = re.match(r'Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)', line.strip())
    sensor = Sensor(
        position=Coordinates(
            x=int(match.group(1)),
            y=int(match.group(2))
        ),
        closest_beacon=Coordinates(
            x=int(match.group(3)),
            y=int(match.group(4))
        )
    )
    sensor.beacon_distance = sensor.position.manhattan_distance(sensor.closest_beacon)

    sensors.append(sensor)



row_coverage = set()

for sensor in sensors:
    y_distance = abs(sensor.position.y-scan_row)

    if y_distance <= sensor.beacon_distance:
        x_distance = (sensor.beacon_distance - y_distance)
        min_x = sensor.position.x - x_distance
        max_x = sensor.position.x + x_distance

        row_coverage.update(range(min_x, max_x+1))


for sensor in sensors:
    if ((sensor.position.y == scan_row and (x := sensor.position.x) in row_coverage)
            or (sensor.closest_beacon.y == scan_row and (x := sensor.closest_beacon.x) in row_coverage)):
        row_coverage.remove(x)

print(len(row_coverage))