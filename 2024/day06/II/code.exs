defmodule M do
  def is_loopy?(obstacles, current, visited_map, size) do
    {current_x, current_y, _} = current
    {size_x, size_y} = size

    if !between?(current_x, 0, size_x) || !between?(current_y, 0, size_y) do
      false
    else
      if MapSet.member?(visited_map, current) do
        true
      else
        visited_map = MapSet.put(visited_map, current)

        next = step(obstacles, current, size)

        is_loopy?(obstacles, next, visited_map, size)
      end
    end
  end

  def between?(value, min, max) do
    value >= min && value < max
  end

  def turn(direction) do
    case direction do
      :left -> :up
      :up -> :right
      :right -> :down
      :down -> :left
    end
  end

  def step(obstacles, {current_x, current_y, direction}, {size_x, size_y}) do
    {next_x, next_y} =
      case direction do
        :left -> {current_x - 1, current_y}
        :right -> {current_x + 1, current_y}
        :up -> {current_x, current_y - 1}
        :down -> {current_x, current_y + 1}
      end

    if between?(next_x, 0, size_x) && between?(next_y, 0, size_y) &&
         Enum.member?(obstacles, {next_x, next_y}) do
      step(obstacles, {current_x, current_y, turn(direction)}, {size_x, size_y})
    else
      {next_x, next_y, direction}
    end
  end

  def travel(obstacles, current, visited_list, {size_x, size_y}) do
    {next_x, next_y, direction} = step(obstacles, current, {size_x, size_y})

    if between?(next_x, 0, size_x) && between?(next_y, 0, size_y) do
      visited_list = visited_list ++ [{next_x, next_y, direction}]

      travel(
        obstacles,
        {next_x, next_y, direction},
        visited_list,
        {size_x, size_y}
      )
    else
      visited_list
    end
  end
end

# Read the file and parse the content
content =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.with_index()
  |> Enum.map(fn {line, row} ->
    String.codepoints(line)
    |> Enum.with_index()
    |> Enum.map(fn {cell, col} ->
      {cell, {col, row}}
    end)
  end)

{size_x, size_y} = {Enum.count(Enum.at(content, 0)), Enum.count(content)}
content = List.flatten(content)

{_, {start_x, start_y}} = Enum.find(content, fn x -> elem(x, 0) == "^" end)

obstacles =
  content
  |> Enum.filter(fn {cell, _} -> cell == "#" end)
  |> Enum.map(fn {_, pos} -> pos end)

visit_path =
  M.travel(obstacles, {start_x, start_y, :up}, [], {size_x, size_y})

options =
  visit_path
  |> Enum.uniq_by(fn {x, y, _} -> {x, y} end)

options =
  options
  |> Enum.filter(fn {x, y, _} ->
    M.is_loopy?(obstacles ++ [{x, y}], {start_x, start_y, :up}, MapSet.new(), {size_x, size_y})
  end)

IO.inspect(options |> Enum.count())
