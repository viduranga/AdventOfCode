defmodule M do
  def between?(value, min, max) do
    value >= min && value <= max
  end

  def min_distance(pos = {x, y}, map, obstacles, stop, size = {size_x, size_y}) do
    if pos == stop do
      map
    else
      current_distance = map[pos]

      nexts =
        [
          {x, y - 1},
          {x + 1, y},
          {x, y + 1},
          {x - 1, y}
        ]
        |> Enum.filter(fn {x, y} ->
          between?(x, 0, size_x) and between?(y, 0, size_y) and
            not Enum.member?(obstacles, {x, y})
        end)

      Enum.reduce(nexts, map, fn next, map ->
        if map[next] > current_distance + 1 do
          min_distance(next, Map.put(map, next, current_distance + 1), obstacles, stop, size)
        else
          map
        end
      end)
    end
  end

  def generate_grid(map, {size_x, size_y}, obstacles) do
    for i <- 0..size_y do
      for j <- 0..size_x do
        if Enum.member?(obstacles, {j, i}) do
          "#"
        else
          "."
        end
      end
    end
    |> Enum.map(&Enum.join(&1))
    |> Enum.join("\n")
  end
end

cords =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn cords ->
    String.split(cords, ",", trim: true)
  end)
  |> Enum.map(fn [x, y] ->
    {String.to_integer(x), String.to_integer(y)}
  end)

{size_x, size_y} = {70, 70}

map =
  Map.new(
    Enum.map(
      0..size_x,
      fn x ->
        Enum.map(
          0..size_y,
          fn y ->
            {{x, y}, :infinity}
          end
        )
      end
    )
    |> List.flatten()
  )

map = Map.put(map, {0, 0}, 0)

cords_count = Enum.count(cords)

{map, blocked_at} =
  Enum.reduce_while(cords_count..0, {map, cords_count}, fn stop_at, {map, _} ->
    cords = Enum.take(cords, stop_at)
    map_new = M.min_distance({0, 0}, map, cords, {size_x, size_y}, {size_x, size_y})

    if map_new[{size_x, size_y}] != :infinity do
      {:halt, {map_new, stop_at}}
    else
      {:cont, {map, stop_at}}
    end
  end)

IO.inspect(cords |> Enum.at(blocked_at))
