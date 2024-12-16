defmodule M do
  def add_quadrant({x, y}, {size_x, size_y}) do
    mid_x = div(size_x, 2)
    mid_y = div(size_y, 2)

    quadrant =
      case {x, y} do
        {x, y} when x < mid_x and y < mid_y -> :nw
        {x, y} when x > mid_x and y < mid_y -> :ne
        {x, y} when x < mid_x and y > mid_y -> :sw
        {x, y} when x > mid_x and y > mid_y -> :se
        {x, y} when x == mid_x or y == mid_y -> nil
      end

    {quadrant, {x, y}}
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

size = {size_x, size_y} = {101, 103}

iter = 100

positions_after =
  robots
  |> Enum.map(fn robot ->
    x = rem(robot.x + iter * robot.i, size_x)
    y = rem(robot.y + iter * robot.j, size_y)

    x = if x < 0, do: size_x + x, else: x
    y = if y < 0, do: size_y + y, else: y

    {x, y}
  end)

safe_robots =
  positions_after
  |> Enum.map(&M.add_quadrant(&1, size))
  |> Enum.reject(fn {quadrant, _} -> quadrant == nil end)
  |> Enum.group_by(fn {quadrant, _} -> quadrant end)
  |> Map.values()
  |> Enum.map(&Enum.count(&1))

safe_factor = safe_robots |> Enum.reduce(&Kernel.*/2)

IO.inspect(safe_factor)
