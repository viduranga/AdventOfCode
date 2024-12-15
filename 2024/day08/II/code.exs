defmodule M do
  def is_devisable?(x, by) do
    rem(x, by) == 0
  end

  def is_valid_equation?(lhs, rhs) do
    if Enum.count(lhs) == 0 do
      rhs == 0
    else
      [head | tail] = lhs

      (is_devisable?(rhs, head) && is_valid_equation?(tail, div(rhs, head))) ||
        (rhs >= head && is_valid_equation?(tail, rhs - head))
    end
  end

  def get_harmonics({x, y}, {dx, dy}, {size_x, size_y}) do
    if x < 0 || x >= size_x || y < 0 || y >= size_y do
      []
    else
      [{x, y} | get_harmonics({x + dx, y + dy}, {dx, dy}, {size_x, size_y})]
    end
  end

  def get_antinodes({x1, y1}, {x2, y2}, size) do
    dx = x1 - x2
    dy = y1 - y2

    get_harmonics({x1, y1}, {dx, dy}, size) ++
      get_harmonics({x2, y2}, {-dx, -dy}, size)
  end

  def is_in_grid({x, y}, {size_x, size_y}) do
    x >= 0 && x < size_x && y >= 0 && y < size_y
  end

  def get_combinations(list) do
    for x <- list, y <- list, x != y, do: [x, y]
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

antenna_groups =
  content
  |> Enum.filter(fn {cell, _} -> cell != "." end)
  |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

antinodes =
  antenna_groups
  |> Enum.map(fn {_, locations} ->
    locations
    |> M.get_combinations()
  end)
  |> Stream.flat_map(& &1)
  |> Enum.to_list()
  |> Enum.map(fn [a, b] ->
    M.get_antinodes(a, b, {size_x, size_y})
  end)
  |> List.flatten()
  |> Enum.uniq()

IO.inspect(antinodes |> Enum.count())
