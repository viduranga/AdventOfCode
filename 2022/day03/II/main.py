
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
for line in content_file.readlines():
    compartment_1, compartment_2 = set(line[:len(line) // 2]), set(line[len(line) // 2:])

    total_priority += sum(char_to_priority(c) for c in compartment_1.intersection(compartment_2))

print(total_priority)