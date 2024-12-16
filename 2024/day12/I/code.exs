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

  def perimeter({name, region}, map) do
    region
    |> Enum.reduce(0, fn {x, y}, acc ->
      acc +
        ([
           {x - 1, y},
           {x + 1, y},
           {x, y - 1},
           {x, y + 1}
         ]
         |> Enum.filter(fn {x, y} ->
           map[{x, y}] != name
         end)
         |> Enum.count())
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
