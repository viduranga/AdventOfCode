defmodule M do
  def move_instructions({{from_x, from_y}, {to_x, to_y}}, type, cache) do
    if Map.has_key?(cache, {:instructions, from_x, from_y, to_x, to_y, type}) do
      {cache[{:instructions, from_x, from_y, to_x, to_y, type}], cache}
    else
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

      out =
        cond do
          hor == [] && ver == [] ->
            [[]]

          hor == [] ->
            [ver]

          ver == [] ->
            [hor]

          type == :numeric && from_x == 0 && to_y == 3 ->
            [hor ++ ver]

          type == :numeric && from_y == 3 && to_x == 0 ->
            [ver ++ hor]

          type == :directional && from_y == 0 && to_x == 0 ->
            [ver ++ hor]

          type == :directional && to_y == 0 && from_x == 0 ->
            [hor ++ ver]

          true ->
            [hor ++ ver, ver ++ hor]
        end

      out = out |> Enum.map(fn o -> o ++ ["A"] end)

      Map.put(cache, {:instructions, from_x, from_y, to_x, to_y, type}, out)
      {out, cache}
    end
  end

  @numeric_key_to_coords %{
    "7" => {0, 0},
    "8" => {1, 0},
    "9" => {2, 0},
    "4" => {0, 1},
    "5" => {1, 1},
    "6" => {2, 1},
    "1" => {0, 2},
    "2" => {1, 2},
    "3" => {2, 2},
    "0" => {1, 3},
    "A" => {2, 3}
  }

  @directional_key_to_coords %{
    "^" => {1, 0},
    "A" => {2, 0},
    "<" => {0, 1},
    "v" => {1, 1},
    ">" => {2, 1}
  }

  def numeric_to_directional(line, iter, cache) do
    {costs, cache} =
      (["A"] ++ String.codepoints(line))
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map_reduce(cache, fn [from, to], cache ->
        from_coords = @numeric_key_to_coords[from]
        to_coords = @numeric_key_to_coords[to]

        {instructions, cache} = move_instructions({from_coords, to_coords}, :numeric, cache)

        {costs, cache} =
          Enum.map_reduce(instructions, cache, fn instruction, cache ->
            {cost, cache} =
              (["A"] ++ instruction)
              |> Enum.chunk_every(2, 1, :discard)
              |> Enum.map_reduce(cache, fn [from, to], cache ->
                M.directional_to_directional([from, to], iter, cache)
              end)

            cost = Enum.sum(cost)
            {{instruction, cost}, cache}
          end)

        min_cost = costs |> Enum.min_by(&elem(&1, 1)) |> elem(1)
        {min_cost, cache}
      end)

    {Enum.sum(costs), cache}
  end

  def directional_to_directional([from, to], iter, cache) do
    if Map.has_key?(cache, {:transform, from, to, iter}) do
      {cache[{:transform, from, to, iter}], cache}
    else
      from_coords = @directional_key_to_coords[from]
      to_coords = @directional_key_to_coords[to]

      {instructions, cache} =
        move_instructions({from_coords, to_coords}, :directional, cache)

      {out, cache} =
        if iter == 1 do
          {Enum.map(instructions, &Enum.count/1) |> Enum.min(), cache}
        else
          {costs, cache} =
            Enum.map_reduce(instructions, cache, fn instruction, cache ->
              {cost, cache} =
                (["A"] ++ instruction)
                |> Enum.chunk_every(2, 1, :discard)
                |> Enum.map_reduce(cache, fn [from, to], cache ->
                  M.directional_to_directional([from, to], iter - 1, cache)
                end)

              cost = Enum.sum(cost)
              {{instruction, cost}, cache}
            end)

          min_cost = costs |> Enum.map(&elem(&1, 1)) |> Enum.min()

          {min_cost, cache}
        end

      cache = Map.put(cache, {:transform, from, to, iter}, out)

      {out, cache}
    end
  end
end

codes =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)

{costs, _} =
  codes
  |> Enum.map_reduce(%{}, fn code, cache ->
    M.numeric_to_directional(code, 25, cache)
  end)

complexity =
  Enum.zip([codes, costs])
  |> Enum.map(fn {code, cost} ->
    {code, _} = String.split_at(code, -1)
    code = String.to_integer(code)
    cost * code
  end)

IO.inspect(complexity |> Enum.sum())
