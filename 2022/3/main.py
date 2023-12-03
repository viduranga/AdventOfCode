from enum import Enum

strategy_file = open('input.txt', 'r')


class Choice(Enum):
    ROCK = 0
    PAPER = 1
    SCISSORS = 2


input_map = {
    'A': Choice.ROCK,
    'B': Choice.PAPER,
    'C': Choice.SCISSORS,
    'X': Choice.ROCK,
    'Y': Choice.PAPER,
    'Z': Choice.SCISSORS,
}

choice_marks = {
    Choice.ROCK: 1,
    Choice.PAPER: 2,
    Choice.SCISSORS: 3
}

win_marks = {
    (Choice.ROCK, Choice.ROCK): 3,
    (Choice.ROCK, Choice.PAPER): 6,
    (Choice.ROCK, Choice.SCISSORS): 0,
    (Choice.PAPER, Choice.ROCK): 0,
    (Choice.PAPER, Choice.PAPER): 3,
    (Choice.PAPER, Choice.SCISSORS): 6,
    (Choice.SCISSORS, Choice.ROCK): 6,
    (Choice.SCISSORS, Choice.PAPER): 0,
    (Choice.SCISSORS, Choice.SCISSORS): 3,
}

score = 0
for line in strategy_file.readlines():
    line = line.strip()
    choice_1, choice_2 = [input_map[choice] for choice in line.split(' ')]

    score += choice_marks[choice_2] + win_marks[(choice_1, choice_2)]

print(score)
