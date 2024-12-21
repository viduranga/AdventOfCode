defmodule M do
  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def cheat_count(map, min_diff) do
    path_blocks =
      map
      |> Enum.filter(fn {_, {x, _}} -> x in [:S, :E, :.] end)
      |> Enum.map(fn {pos, {_, dist}} -> {pos, dist} end)
      |> Enum.sort(fn {_, a}, {_, b} -> a < b end)

    path_blocks
    |> Enum.map(fn {pos, dist} ->
      path_blocks
      |> Enum.filter(fn {p, d} ->
        diff = manhattan_distance(pos, p)

        diff <= 20 && d - dist - diff >= min_diff
      end)
      |> Enum.map(fn p -> {{pos, dist}, p} end)
      |> Enum.count()
    end)
    |> Enum.filter(fn x -> x != [] end)
    |> Enum.sum()
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

IO.inspect(M.cheat_count(distance_map, min_distance))
