import re
from dataclasses import dataclass

import numpy as np

input_file = open('test.txt', 'r')


@dataclass
class Collection:
    ore: int = 0
    clay: int = 0
    obsidian: int = 0
    geode: int = 0

    def __add__(self, other):
        return Collection(
            self.ore + other.ore,
            self.clay + other.clay,
            self.obsidian + other.obsidian,
            self.geode + other.geode,
        )

    def __lt__(self, other):
        return (self.ore < other.ore and
                self.clay < other.clay and
                self.obsidian < other.obsidian and
                self.geode < other.geode)

    def __eq__(self, other):
        return (self.ore == other.ore and
                self.clay == other.clay and
                self.obsidian == other.obsidian and
                self.geode == other.geode)

    def __le__(self, other):
        return (self.ore <= other.ore and
                self.clay <= other.clay and
                self.obsidian <= other.obsidian and
                self.geode <= other.geode)

    def __sub__(self, other):
        return Collection(
            self.ore - other.ore,
            self.clay - other.clay,
            self.obsidian - other.obsidian,
            self.geode - other.geode)


@dataclass
class Blueprint:
    id: int
    ore_robot_cost: Collection
    clay_robot_cost: Collection
    obsidian_robot_cost: Collection
    geode_robot_cost: Collection


blueprints = []

for line in input_file.readlines():
    match = re.match(
        r'Blueprint (\d+): Each ore robot costs (\d+) ore\. Each clay robot costs (\d+) ore\. Each obsidian robot costs (\d+) ore and (\d+) clay\. Each geode robot costs (\d+) ore and (\d+) obsidian\.',
        line.strip())

    blueprint = Blueprint(
        id=int(match.group(1)),
        ore_robot_cost=Collection(ore=int(match.group(2))),
        clay_robot_cost=Collection(ore=int(match.group(3))),
        obsidian_robot_cost=Collection(ore=int(match.group(4)), clay=int(match.group(5))),
        geode_robot_cost=Collection(ore=int(match.group(6)), obsidian=int(match.group(7))),
    )
    blueprints.append(blueprint)


def max_geodes(blueprint, minute, collected, robots):
    new_collected = collected + robots

    if minute == 21:
        return new_collected

    collections = []
    if blueprint.ore_robot_cost <= collected:
        collections.append(max_geodes(blueprint, minute + 1, new_collected - blueprint.ore_robot_cost,
                                      robots + Collection(ore=1)))
    if blueprint.clay_robot_cost <= collected:
        collections.append(max_geodes(blueprint, minute + 1, new_collected - blueprint.clay_robot_cost,
                                      robots + Collection(clay=1)))
    if blueprint.obsidian_robot_cost <= collected:
        collections.append(max_geodes(blueprint, minute + 1, new_collected - blueprint.obsidian_robot_cost,
                                      robots + Collection(obsidian=1)))
    if blueprint.geode_robot_cost <= collected:
        collections.append(max_geodes(blueprint, minute + 1, new_collected - blueprint.geode_robot_cost,
                                      robots + Collection(geode=1)))

    collections.append(max_geodes(blueprint, minute + 1, collected + robots, robots))

    return max(collections, key=lambda c: c.geode)


# max_geodes_count = max([max_geodes(blueprint, 1, Collection(), Collection(ore=1)) for blueprint in blueprints])
# print(max_geodes_count)
print(max_geodes(blueprints[0], 1, Collection(), Collection(ore=1)))
