import re

content_file = open('input.txt', 'r')

char_count = 0

start_bit = None
while c := content_file.read(1):
    if start_bit is None:
        start_bit = c * 14
    char_count += 1
    start_bit = start_bit[1:] + c

    if len(set(start_bit)) == 14:
        print(char_count)
        break
