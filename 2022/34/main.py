from dataclasses import dataclass

import numpy as np

input_file = open('input.txt', 'r')

jet_pattern = input_file.read()


@dataclass
class Coordinates:
    r: int
    c: int

chamber_height = 2022*3
chamber_width = 7


@dataclass
class Shape:
    units: list[Coordinates]
    top_row: int

    @staticmethod
    def create_shape(shape, start_r):
        if shape == '-':
            return Shape(units=[Coordinates(start_r, 2),
                                Coordinates(start_r, 3),
                                Coordinates(start_r, 4),
                                Coordinates(start_r, 5)],
                         top_row=start_r)
        elif shape == '+':
            return Shape(units=[Coordinates(start_r + 1, 2),
                                Coordinates(start_r, 3),
                                Coordinates(start_r + 1, 3),
                                Coordinates(start_r + 2, 3),
                                Coordinates(start_r + 1, 4)],
                         top_row=start_r + 2)
        elif shape == 'J':
            return Shape(units=[Coordinates(start_r, 2),
                                Coordinates(start_r, 3),
                                Coordinates(start_r, 4),
                                Coordinates(start_r + 1, 4),
                                Coordinates(start_r + 2, 4)],
                         top_row=start_r + 2)
        elif shape == 'I':
            return Shape(units=[Coordinates(start_r, 2),
                                Coordinates(start_r + 1, 2),
                                Coordinates(start_r + 2, 2),
                                Coordinates(start_r + 3, 2)],
                         top_row=start_r + 3)
        elif shape == 'O':
            return Shape(units=[Coordinates(start_r, 2),
                                Coordinates(start_r + 1, 2),
                                Coordinates(start_r, 3),
                                Coordinates(start_r + 1, 3)],
                         top_row=start_r + 1)

    def left(self, grid):
        if any(unit.c-1 < 0 or grid[unit.r, unit.c-1] != '.' for unit in self.units):
            return False

        for unit in self.units:
            unit.c -= 1

        return True

    def right(self, grid):
        if any(unit.c+1 >= chamber_width or  grid[unit.r, unit.c+1] != '.' for unit in self.units):
            return False

        for unit in self.units:
            unit.c += 1

        return True

    def down(self, grid):
        if any(unit.r-1 < 0 or grid[unit.r-1, unit.c] != '.' for unit in self.units):
            return False

        for unit in self.units:
            unit.r -= 1

        self.top_row -= 1

        return True


grid = np.full((chamber_height, chamber_width), '.')
max_rock_height = 0

def generate_shape_iterator():
    shape_order = ['-', '+', 'J', 'I', 'O']
    shape_count = 5
    i = 0
    while True:
        yield Shape.create_shape(shape_order[i % shape_count], max_rock_height+3)
        i += 1

def generate_jet_iterator():
    jet_pattern_len = len(jet_pattern)
    i = 0
    while True:
        yield jet_pattern[i % jet_pattern_len]
        i += 1


def add_rock_to_grid(rock: Shape, grid):
    for unit in rock.units:
        grid[unit.r, unit.c] = '#'


shape_iterator = generate_shape_iterator()
jet_iterator = generate_jet_iterator()

for i in range(2022):
    shape = next(shape_iterator)

    while True:
        jet = next(jet_iterator)

        if jet == '<':
            shape.left(grid)
        elif jet == '>':
            shape.right(grid)

        moved = shape.down(grid)

        if not moved:
            add_rock_to_grid(shape, grid)
            max_rock_height = max(max_rock_height, shape.top_row+1)
            break


print(max_rock_height)
