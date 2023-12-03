calories_file = open('input.txt', 'r')

max_calories = 0
current_calories = 0
for line in calories_file.readlines():
    line = line.strip()
    if line == "":
        max_calories = max(max_calories, current_calories)
        current_calories = 0
    else:
        current_calories += int(line)

print(max_calories)
