import ast

input_file = open('input.txt', 'r')

pairs = []

lines = input_file.readlines()

for i in range(0, len(lines), 3):
    pairs.append((ast.literal_eval(lines[i]), ast.literal_eval(lines[i+1])))


def is_in_order(left, right):
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

            sub_in_order = is_in_order(left_item, right_item)

            if sub_in_order is not None:
                return sub_in_order

        i += 1

    if i == len(left) and i < len(right):
        return True


id_sum = 0

for i, pair in enumerate(pairs, 1):
    if is_in_order(*pair):
        print(i)
        id_sum += i

print(f"{id_sum=}")