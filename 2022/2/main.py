from queue import PriorityQueue

calories_file = open('input.txt', 'r')

calories = PriorityQueue()
current_calories = 0
for line in calories_file.readlines():
    line = line.strip()
    if line == "":
        calories.put(-1*current_calories)
        current_calories = 0
    else:
        current_calories += int(line)

top_3 = [-1*calories.get() for _ in range(3)]
print(top_3)
print(sum(top_3))
