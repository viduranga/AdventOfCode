from enum import Enum

strategy_file = open('input.txt', 'r')


class Choice(Enum):
    ROCK = 0
    PAPER = 1
    SCISSORS = 2


class State(Enum):
    WIN = 0
    DRAW = 1
    LOSE = 2


input_map = {
    'A': Choice.ROCK,
    'B': Choice.PAPER,
    'C': Choice.SCISSORS,
    'X': State.LOSE,
    'Y': State.DRAW,
    'Z': State.WIN
}

choice_marks = {
    Choice.ROCK: 1,
    Choice.PAPER: 2,
    Choice.SCISSORS: 3
}

state_marks = {
    State.WIN: 6,
    State.DRAW: 3,
    State.LOSE: 0
}

choice_map = {
    (Choice.ROCK, State.LOSE): Choice.SCISSORS,
    (Choice.ROCK, State.DRAW): Choice.ROCK,
    (Choice.ROCK, State.WIN): Choice.PAPER,
    (Choice.PAPER, State.LOSE): Choice.ROCK,
    (Choice.PAPER, State.DRAW): Choice.PAPER,
    (Choice.PAPER, State.WIN): Choice.SCISSORS,
    (Choice.SCISSORS, State.LOSE): Choice.PAPER,
    (Choice.SCISSORS, State.DRAW): Choice.SCISSORS,
    (Choice.SCISSORS, State.WIN): Choice.ROCK,
}

score = 0
for line in strategy_file.readlines():
    line = line.strip()
    choice, state = [input_map[choice] for choice in line.split(' ')]

    my_choice = choice_map[(choice, state)]

    score += choice_marks[my_choice] + state_marks[state]

print(score)
