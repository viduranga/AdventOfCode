
content_file = open('input.txt', 'r')

overlap_assignment_count = 0
for line in content_file.readlines():
    p1, p2 = line.split(',')

    p1_s, p1_e = [int(s) for s in p1.split('-')]
    p2_s, p2_e = [int(s) for s in p2.split('-')]

    if max(p1_s, p2_s) <= min(p1_e, p2_e):
        overlap_assignment_count += 1


print(overlap_assignment_count)