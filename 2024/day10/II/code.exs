defmodule M do
  def between?(value, min, max) do
    value >= min && value < max
  end

  def travel(current = {current_x, current_y}, visited, map, size = {size_x, size_y}) do
    visited = MapSet.put(visited, current)
    current_val = map[current]

    if current_val == 9 do
      {[current], visited}
    else
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
            map[next] == current_val + 1 &&
            !MapSet.member?(visited, next)
        end)

      case nexts do
        [] ->
          {[], visited}

        _ ->
          Enum.reduce(nexts, {[], visited}, fn next, {hits, visited} ->
            {path_hits, _} = M.travel(next, visited, map, size)
            hits = hits ++ path_hits
            {hits, visited}
          end)
      end
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
      {String.to_integer(cell), {col, row}}
    end)
  end)

size = {Enum.count(Enum.at(content, 0)), Enum.count(content)}

content = List.flatten(content)

trailheads = for cell = {0, _} <- content, do: cell

map = content |> Map.new(fn {cell, pos} -> {pos, cell} end)

summits =
  trailheads
  |> Enum.map(fn {_, trailhead} -> M.travel(trailhead, MapSet.new(), map, size) |> elem(0) end)

summit_scores = Enum.map(summits, &Enum.count(&1))
IO.inspect(summit_scores |> Enum.sum())
