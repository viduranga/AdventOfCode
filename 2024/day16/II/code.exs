defmodule M do
  def between?(value, min, max) do
    value >= min && value < max
  end

  def next_options({x, y}, facing) do
    straight =
      case facing do
        :N -> {facing, {x, y - 1}}
        :E -> {facing, {x + 1, y}}
        :S -> {facing, {x, y + 1}}
        :W -> {facing, {x - 1, y}}
      end

    left =
      case facing do
        :N -> {:W, {x - 1, y}}
        :W -> {:S, {x, y + 1}}
        :S -> {:E, {x + 1, y}}
        :E -> {:N, {x, y - 1}}
      end

    right =
      case facing do
        :N -> {:E, {x + 1, y}}
        :E -> {:S, {x, y + 1}}
        :S -> {:W, {x - 1, y}}
        :W -> {:N, {x, y - 1}}
      end

    {straight, left, right}
  end

  def distance(prev_distance, pos, facing, map) do
    {{straight_facing, straight_cord}, {left_facing, left_cord}, {right_facing, right_cord}} =
      next_options(pos, facing)

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

  def min_distance(start, map) do
    distance_map = M.distance(0, start, :E, map)

    {_, {_, min_distance}} =
      distance_map
      |> Map.to_list()
      |> Enum.find(fn {_, {x, _}} -> x == :E end)

    {min_distance, distance_map}
  end

  def paths(prev_distance, pos, facing, map, target, path) do
    path = path ++ [pos]

    {{straight_facing, straight_cord}, {left_facing, left_cord}, {right_facing, right_cord}} =
      next_options(pos, facing)

    case map[pos] do
      {:"#", _} ->
        []

      {:E, _} ->
        [{prev_distance + 1, path}]

      {_, current_distance} ->
        # Wierd thing. I want to discount the fact that the previous score, although it's low
        # might need to turn next
        if current_distance + 1000 >= prev_distance + 1 do
          straight_paths =
            if Enum.member?(path, straight_cord) do
              []
            else
              paths(prev_distance + 1, straight_cord, straight_facing, map, target, path)
            end

          left_paths =
            if Enum.member?(path, left_cord) do
              []
            else
              paths(prev_distance + 1001, left_cord, left_facing, map, target, path)
            end

          right_paths =
            if Enum.member?(path, right_cord) do
              []
            else
              paths(prev_distance + 1001, right_cord, right_facing, map, target, path)
            end

          straight_paths ++ left_paths ++ right_paths
        else
          []
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

{min_distance, distance_map} = M.min_distance(start, map)

min_paths =
  M.paths(0, start, :E, distance_map, min_distance, [])
  |> Enum.filter(fn {distance, _} -> distance == min_distance end)

tiles = min_paths |> Enum.map(&elem(&1, 1)) |> Enum.reduce(&Kernel.++/2) |> Enum.uniq()
IO.inspect(tiles |> Enum.count())
