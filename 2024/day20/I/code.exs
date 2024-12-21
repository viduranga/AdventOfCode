defmodule M do
  def safe_diff(nil, _) do
    -1
  end

  def safe_diff(_, nil) do
    -1
  end

  def safe_diff({_, a}, {_, b}) do
    if a == :infinity or b == :infinity do
      -1
    else
      abs(a - b)
    end
  end

  def cheat_count(map, min_diff) do
    barriers =
      map |> Enum.filter(fn {_, {x, _}} -> x == :"#" end) |> Enum.map(fn {pos, _} -> pos end)

    barriers
    |> Enum.filter(fn {x, y} ->
      horizontal_diff = safe_diff(map[{x - 1, y}], map[{x + 1, y}])
      vertical_diff = safe_diff(map[{x, y - 1}], map[{x, y + 1}])

      horizontal_diff > min_diff or vertical_diff > min_diff
    end)
    |> Enum.count()
  end

  def distance(prev_distance, pos = {x, y}, map) do
    case map[pos] do
      nil ->
        map

      {:"#", _} ->
        map

      {current, :infinity} ->
        map = Map.put(map, pos, {current, prev_distance})

        if current != :E do
          [
            {x, y - 1},
            {x + 1, y},
            {x, y + 1},
            {x - 1, y}
          ]
          |> Enum.reduce(map, fn next, map ->
            distance(prev_distance + 1, next, map)
          end)
        else
          map
        end

      _ ->
        map
    end
  end
end

[file, min_distance] = System.argv()
min_distance = String.to_integer(min_distance)

map =
  file
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.with_index()
  |> Enum.map(fn {line, row} ->
    String.codepoints(line)
    |> Enum.with_index()
    |> Enum.map(fn {cell, col} ->
      {{col, row}, {String.to_atom(cell), :infinity}}
    end)
  end)
  |> List.flatten()
  |> Map.new()

{start, _} = map |> Map.to_list() |> Enum.find(fn {_, {x, _}} -> x == :S end)

distance_map = M.distance(0, start, map)

# IO.inspect(distance_map)
IO.inspect(M.cheat_count(distance_map, min_distance))
