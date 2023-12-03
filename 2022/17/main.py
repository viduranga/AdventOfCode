from dataclasses import dataclass
from enum import Enum

content_file = open('input.txt', 'r')


class Positioning(Enum):
    ADJACENT = 0
    UP = 1
    DOWN = 2
    LEFT = 3
    RIGHT = 4
    UP_LEFT = 5
    DOWN_LEFT = 6
    UP_RIGHT = 7
    DOWN_RIGHT = 8


@dataclass
class Coordinates:
    x: int
    y: int

    def get_positioning(self, second):
        if abs(self.x-second.x) <= 1 and abs(self.y-second.y) <= 1:
            return Positioning.ADJACENT
        elif second.x == self.x:
            if second.y > self.y:
                return Positioning.UP
            elif second.y < self.y:
                return Positioning.DOWN
        elif second.x < self.x:
            if second.y == self.y:
                return Positioning.LEFT
            elif second.y > self.y:
                return Positioning.UP_LEFT
            elif second.y < self.y:
                return Positioning.DOWN_LEFT
        elif second.x > self.x:
            if second.y == self.y:
                return Positioning.RIGHT
            elif second.y > self.y:
                return Positioning.UP_RIGHT
            elif second.y < self.y:
                return Positioning.DOWN_RIGHT


def move_tail(head: Coordinates, tail: Coordinates):
    positioning = head.get_positioning(tail)
    if positioning == Positioning.ADJACENT:
        return tail
    elif positioning == Positioning.UP:
        return Coordinates(x=tail.x, y=tail.y-1)
    elif positioning == Positioning.DOWN:
        return Coordinates(x=tail.x, y=tail.y+1)
    elif positioning == Positioning.LEFT:
        return Coordinates(x=tail.x+1, y=tail.y)
    elif positioning == Positioning.RIGHT:
        return Coordinates(x=tail.x-1, y=tail.y)
    elif positioning == Positioning.UP_LEFT:
        return Coordinates(x=tail.x+1, y=tail.y-1)
    elif positioning == Positioning.UP_RIGHT:
        return Coordinates(x=tail.x-1, y=tail.y-1)
    elif positioning == Positioning.DOWN_RIGHT:
        return Coordinates(x=tail.x-1, y=tail.y+1)
    elif positioning == Positioning.DOWN_LEFT:
        return Coordinates(x=tail.x+1, y=tail.y+1)


head = Coordinates(x=0, y=0)
tail = Coordinates(x=0, y=0)

tail_path = [(0, 0)]
for line in content_file.readlines():

    direction, count = line.strip().split(' ')
    count = int(count)

    for i in range(count):
        if direction == 'R':
            head.x = head.x+1
        if direction == 'L':
            head.x = head.x-1
        if direction == 'U':
            head.y = head.y+1
        if direction == 'D':
            head.y = head.y-1

        tail = move_tail(head, tail)
        tail_path.append((tail.x, tail.y))


print(min(tail_path))
print(len(set(tail_path)))