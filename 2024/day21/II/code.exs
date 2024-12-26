defmodule M do
  def move_instructions({{from_x, from_y}, {to_x, to_y}}, cost, type) do
    hor =
      if from_x < to_x do
        for _ <- 1..(to_x - from_x)//1, do: ">"
      else
        for _ <- 1..(from_x - to_x)//1, do: "<"
      end

    ver =
      if from_y < to_y do
        for _ <- 1..(to_y - from_y)//1, do: "v"
      else
        for _ <- 1..(from_y - to_y)//1, do: "^"
      end

    cond do
      hor == [] && ver == [] ->
        []

      hor == [] ->
        ver

      ver == [] ->
        hor

      type == :numeric && from_x == 0 && to_y == 3 ->
        hor ++ ver

      type == :numeric && from_y == 3 && to_x == 0 ->
        ver ++ hor

      type == :directional && from_y == 0 && to_x == 0 ->
        ver ++ hor

      type == :directional && to_y == 0 && from_x == 0 ->
        hor ++ ver

      true ->
        hor_start = Enum.at(hor, 0)
        ver_start = Enum.at(ver, 0)

        hor_first_cost =
          cost["A#{hor_start}"] + cost["#{hor_start}#{ver_start}"] + cost["#{ver_start}A"]

        ver_first_cost =
          cost["A#{ver_start}"] + cost["#{ver_start}#{hor_start}"] + cost["#{hor_start}A"]

        if hor_first_cost < ver_first_cost do
          hor ++ ver
        else
          ver ++ hor
        end
    end
  end

  def numeric_key_to_coords(key) do
    case key do
      "7" -> {0, 0}
      "8" -> {1, 0}
      "9" -> {2, 0}
      "4" -> {0, 1}
      "5" -> {1, 1}
      "6" -> {2, 1}
      "1" -> {0, 2}
      "2" -> {1, 2}
      "3" -> {2, 2}
      "0" -> {1, 3}
      "A" -> {2, 3}
    end
  end

  def directional_key_to_coords(key) do
    case key do
      "^" -> {1, 0}
      "A" -> {2, 0}
      "<" -> {0, 1}
      "v" -> {1, 1}
      ">" -> {2, 1}
    end
  end

  def numeric_to_directional([from, to], cost) do
    from_coords = numeric_key_to_coords(from)
    to_coords = numeric_key_to_coords(to)

    move_instructions({from_coords, to_coords}, cost, :numeric) ++ ["A"]
  end

  def directional_to_directional([from, to], cost, iter, cache) do
    if Map.has_key?(cache, {from, to, iter}) do
      {cache[{from, to, iter}], cache}
    else
      from_coords = directional_key_to_coords(from)
      to_coords = directional_key_to_coords(to)

      instructions = move_instructions({from_coords, to_coords}, cost, :directional) ++ ["A"]

      {out, cache} =
        if iter > 1 do
          {out, cache} =
            (["A"] ++ instructions)
            |> Enum.chunk_every(2, 1, :discard)
            |> Enum.map_reduce(cache, fn [from, to], cache ->
              M.directional_to_directional([from, to], cost, iter - 1, cache)
            end)

          out =
            out
            |> List.flatten()

          {out, cache}
        else
          {instructions, cache}
        end

      cache = Map.put(cache, {from, to, iter}, out)

      {out, cache}
    end
  end
end

cost = %{
  "A<" => 9,
  "A^" => 7,
  "A>" => 5,
  "Av" => 8,
  "^<" => 8,
  "^v" => 6,
  "^>" => 9,
  "^A" => 3,
  "v^" => 4,
  "v>" => 3,
  "vA" => 6,
  "v<" => 8,
  "<A" => 7,
  "<^" => 6,
  "<v" => 4,
  "<>" => 5,
  ">v" => 7,
  ">A" => 3,
  "><" => 9,
  ">^" => 9
}

codes =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)

directions_1 =
  codes
  |> Enum.map(fn line ->
    String.codepoints(line)
  end)
  |> Enum.map(fn code ->
    (["A"] ++ code)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [from, to] ->
      M.numeric_to_directional([from, to], cost)
    end)
    |> List.flatten()
  end)

{directions, _} =
  directions_1
  |> Enum.map_reduce(%{}, fn code, cache ->
    {out, cache} =
      (["A"] ++ code)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map_reduce(cache, fn [from, to], cache ->
        M.directional_to_directional([from, to], cost, 25, cache)
      end)

    out =
      out
      |> List.flatten()

    {out, cache}
  end)

complexity =
  Enum.zip([codes, directions])
  |> Enum.map(fn {code, directions} ->
    {code, _} = String.split_at(code, -1)
    code = String.to_integer(code)
    Enum.count(directions) * code
  end)

IO.inspect(complexity |> Enum.sum())

# {start, _} = map |> Map.to_list() |> Enum.find(fn {_, {x, _}} -> x == :S end)
#
# distance_map = M.distance(0, start, map)
#
# # IO.inspect(distance_map)
# IO.inspect(M.cheat_count(distance_map, min_distance))
