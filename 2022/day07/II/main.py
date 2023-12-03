from dataclasses import dataclass, field
from typing import Any

content_file = open('input.txt', 'r')

char_count = 0

lines = content_file.readlines()


@dataclass
class Directory:
    size = 0
    files: dict = field(default_factory=dict)
    parent: Any = None
    children: dict = field(default_factory=dict)


root = None

line_id = 0
current = None
while line_id < len(lines):
    line = lines[line_id].strip()
    line_id += 1

    if line[0] == "$":
        if line[2:4] == "cd":
            dir_name = line[5:]

            if dir_name != "..":
                if current is None:
                    directory = Directory()
                    current = directory
                    root = directory
                else:
                    current = current.children[dir_name]
            else:
                current = current.parent
        elif line[2:4] == "ls":
            while line_id < len(lines):
                line = lines[line_id].strip()
                line_id += 1

                if line[0] == "$":
                    line_id -= 1
                    break
                else:
                    cmd_1, name = line.split(' ')
                    if cmd_1 == "dir":
                        new = Directory(parent=current)
                        current.children[name] = new
                    else:
                        file_size = int(cmd_1)
                        current.files[name] = file_size

                        update_dir = current
                        while update_dir:
                            update_dir.size += file_size
                            update_dir = update_dir.parent


required = root.size - 40000000

travel_list = [root]
delete_size = root.size

while travel_list:
    current = travel_list.pop()
    if current.size >= required:
        delete_size = min(delete_size, current.size)

    travel_list.extend(current.children.values())

print(delete_size)