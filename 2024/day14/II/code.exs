defmodule M do
  def move({{x, y}, {i, j}}, steps, {size_x, size_y}) do
    x = rem(x + steps * i, size_x)
    y = rem(y + steps * j, size_y)

    x = if x < 0, do: size_x + x, else: x
    y = if y < 0, do: size_y + y, else: y

    {{x, y}, {i, j}}
  end

  def generate_grid(robots, {size_x, size_y}) do
    robot_loc =
      robots
      |> Enum.map(fn {{x, y}, _} -> {x, y} end)

    for i <- 0..(size_x - 1) do
      for j <- 0..(size_y - 1) do
        if {i, j} in robot_loc do
          "X"
        else
          "."
        end
      end
    end
    |> Enum.map(&Enum.join(&1))
    |> Enum.join("\n")
  end

  def is_possible_pattern?(grid) do
    String.contains?(grid, ["XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"])
  end

  def step(_, 10000, _), do: nil

  def step(robots, count, size) do
    grid = generate_grid(Enum.map(robots, &move(&1, count, size)), size)

    if is_possible_pattern?(grid) do
      IO.puts("______________________ #{count} ______________________")
      IO.puts(grid)
    end

    step(robots, count + 1, size)
  end
end

content =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)

robots =
  content
  |> Enum.map(fn line ->
    Regex.named_captures(
      ~r/^p=(?<x>\d+),(?<y>\d+) v=(?<i>-?\d+),(?<j>-?\d+)$/,
      line
    )
    |> Enum.map(fn {key, val} -> {String.to_atom(key), String.to_integer(val)} end)
    |> Enum.into(%{})
  end)
  |> Enum.map(fn robot -> {{robot.x, robot.y}, {robot.i, robot.j}} end)

size = {101, 103}
# size = {11, 7}

M.step(robots, 1, size)

# iter = 100
#
# positions_after =
#   robots
#   |> Enum.map(fn robot ->
#     x = rem(robot.x + iter * robot.i, size_x)
#     y = rem(robot.y + iter * robot.j, size_y)
#
#     x = if x < 0, do: size_x + x, else: x
#     y = if y < 0, do: size_y + y, else: y
#
#     {x, y}
#   end)
#
# safe_robots =
#   positions_after
#   |> Enum.map(&M.add_quadrant(&1, size))
#   |> Enum.reject(fn {quadrant, _} -> quadrant == nil end)
#   |> Enum.group_by(fn {quadrant, _} -> quadrant end)
#   |> Map.values()
#   |> Enum.map(&Enum.count(&1))
#
# safe_factor = safe_robots |> Enum.reduce(&Kernel.*/2)
#
# IO.inspect(safe_factor)
