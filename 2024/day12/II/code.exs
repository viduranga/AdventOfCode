defmodule M do
  def between?(value, min, max) do
    value >= min && value < max
  end

  def explore(name, current = {current_x, current_y}, size = {size_x, size_y}, map, visited) do
    visited = MapSet.put(visited, current)

    nexts =
      [
        {current_x - 1, current_y},
        {current_x + 1, current_y},
        {current_x, current_y - 1},
        {current_x, current_y + 1}
      ]
      |> Enum.filter(fn next = {x, y} ->
        M.between?(x, 0, size_x) &&
          M.between?(y, 0, size_y) &&
          map[next] == name &&
          !MapSet.member?(visited, next)
      end)

    case nexts do
      [] ->
        {[current], visited}

      _ ->
        Enum.reduce(nexts, {[current], visited}, fn next, {hits, visited} ->
          {path_hits, path_visited} = M.explore(name, next, size, map, visited)
          hits = hits ++ path_hits
          visited = MapSet.union(visited, path_visited)
          {hits, visited}
        end)
    end
  end

  def group_regions(map, size) do
    map
    |> Enum.reduce({MapSet.new(), []}, fn {loc, name}, {visited, regions} ->
      case MapSet.member?(visited, loc) do
        true ->
          {visited, regions}

        false ->
          {region, visited} = M.explore(name, loc, size, map, visited)
          {visited, regions ++ [{name, region |> Enum.uniq()}]}
      end
    end)
  end

  def count_outside_corners(name, {x, y}, map) do
    up = {x, y - 1}
    down = {x, y + 1}
    left = {x - 1, y}
    right = {x + 1, y}

    upleft = {x - 1, y - 1}
    upright = {x + 1, y - 1}
    downleft = {x - 1, y + 1}
    downright = {x + 1, y + 1}

    [up, upright, right, downright, down, downleft, left, upleft, up]
    |> Enum.chunk_every(3, 2, :discard)
    |> Enum.filter(fn [a, h, b] ->
      map[a] == name &&
        map[b] == name &&
        map[h] != name
    end)
    |> Enum.count()
  end

  def count_inside_corners(name, {x, y}, map) do
    up = {x, y - 1}
    down = {x, y + 1}
    left = {x - 1, y}
    right = {x + 1, y}

    [up, right, down, left, up]
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.filter(fn [a, b] ->
      map[a] != name &&
        map[b] != name
    end)
    |> Enum.count()
  end

  def perimeter({name, region}, map) do
    region
    |> Enum.reduce(0, fn {x, y}, acc ->
      acc + M.count_outside_corners(name, {x, y}, map) +
        M.count_inside_corners(name, {x, y}, map)
    end)
  end

  def area({_, region}) do
    region
    |> Enum.count()
  end
end

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

size = {Enum.count(Enum.at(content, 0)), Enum.count(content)}

content = List.flatten(content)

map = content |> Map.new(fn {cell, pos} -> {pos, cell} end)

regions = M.group_regions(map, size) |> elem(1)

IO.inspect(
  regions
  |> Enum.map(fn region ->
    M.perimeter(region, map) * M.area(region)
  end)
  |> Enum.sum()
)
