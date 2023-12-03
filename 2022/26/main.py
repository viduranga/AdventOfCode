import ast
from dataclasses import dataclass
from typing import List

input_file = open('input.txt', 'r')


@dataclass
class Packet:
    data: List = None

    def is_in_order(self, left, right):
        i = 0

        while i < len(left):
            if i >= len(right):
                return False

            left_item = left[i]
            right_item = right[i]
            if isinstance(left_item, int) and isinstance(right_item, int):
                if left_item < right_item:
                    return True
                elif left_item > right_item:
                    return False
            else:
                if isinstance(left_item, int):
                    left_item = [left_item]

                if isinstance(right_item, int):
                    right_item = [right_item]

                sub_in_order = self.is_in_order(left_item, right_item)

                if sub_in_order is not None:
                    return sub_in_order

            i += 1

        if i == len(left) and i < len(right):
            return True

    def __lt__(self, other):
        return self.is_in_order(self.data, other.data)

    def __le__(self, other):
        return self.is_in_order(self.data, other.data)


divider_1 = Packet(data=[[2]])
divider_2 = Packet(data=[[6]])
packets = [divider_1, divider_2]

lines = input_file.readlines()

for line in lines:
    line = line.strip()
    if line:
        packets.append(Packet(data=ast.literal_eval(line)))


sorted = sorted(packets)

print(f"{(sorted.index(divider_1) + 1) * (sorted.index(divider_2) + 1)}")