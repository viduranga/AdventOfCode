
def char_to_priority(char: str):
    # a through z have priorities 1 through 26
    # A through Z have priorities 27 through 52
    ascii_val = ord(char)

    if 97 <= ascii_val <= 122:  # lowercase:
        return ascii_val - ord('a') + 1
    else:  # uppercase
        return ascii_val - ord('A') + 27


content_file = open('input.txt', 'r')

total_priority = 0
lines = content_file.readlines()
for group_id in range(len(lines)//3):
    compartment_1 = set(lines[group_id*3].strip())
    compartment_2 = set(lines[group_id*3+1].strip())
    compartment_3 = set(lines[group_id*3+2].strip())

    total_priority += sum(char_to_priority(c) for c in set.intersection(compartment_1, compartment_2, compartment_3))

print(total_priority)