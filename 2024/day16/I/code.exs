defmodule M do
  def between?(value, min, max) do
    value >= min && value < max
  end

  def distance(prev_distance, pos = {x, y}, facing, map) do
    {straight_facing, straight_cord} =
      case facing do
        :N -> {facing, {x, y - 1}}
        :E -> {facing, {x + 1, y}}
        :S -> {facing, {x, y + 1}}
        :W -> {facing, {x - 1, y}}
      end

    {left_facing, left_cord} =
      case facing do
        :N -> {:W, {x - 1, y}}
        :W -> {:S, {x, y + 1}}
        :S -> {:E, {x + 1, y}}
        :E -> {:N, {x, y - 1}}
      end

    {right_facing, right_cord} =
      case facing do
        :N -> {:E, {x + 1, y}}
        :E -> {:S, {x, y + 1}}
        :S -> {:W, {x - 1, y}}
        :W -> {:N, {x, y - 1}}
      end

    case map[pos] do
      {:"#", _} ->
        map

      {current, current_distance} ->
        if current_distance > prev_distance + 1 do
          map = Map.put(map, pos, {current, prev_distance + 1})

          if current != :E do
            map = distance(prev_distance + 1, straight_cord, straight_facing, map)
            map = distance(prev_distance + 1001, left_cord, left_facing, map)
            distance(prev_distance + 1001, right_cord, right_facing, map)
          else
            map
          end
        else
          map
        end
    end
  end
end

map =
  System.argv()
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

distance_map = M.distance(0, start, :E, map)

{_, {_, min_distance}} =
  distance_map
  |> Map.to_list()
  |> Enum.find(fn {_, {x, _}} -> x == :E end)

min_distance = min_distance - 1

IO.inspect(min_distance)
