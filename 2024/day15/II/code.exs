defmodule M do
  def between?(value, min, max) do
    value >= min && value < max
  end

  def get_new_position({x, y}, direction) do
    case direction do
      :^ -> {x, y - 1}
      :v -> {x, y + 1}
      :> -> {x + 1, y}
      :< -> {x - 1, y}
    end
  end

  def shift_box({x, y}, direction, map) do
    current = map[{x, y}]

    {box_1, box_2} =
      case current do
        :"[" ->
          {{x, y}, {x + 1, y}}

        :"]" ->
          {{x - 1, y}, {x, y}}
      end

    case direction do
      :> ->
        shift({x, y}, direction, map)

      :< ->
        shift({x, y}, direction, map)

      x when x in [:^, :v] ->
        box_1_shift = shift(box_1, direction, map)

        case box_1_shift do
          {:ok, _, new_map} ->
            box_2_shift = shift(box_2, direction, new_map)

            case box_2_shift do
              {:ok, _, _} ->
                box_2_shift

              _ ->
                {:blocked, {x, y}, map}
            end

          _ ->
            {:blocked, {x, y}, map}
        end

      :v ->
        shift({x - 1, y}, direction, map)
    end
  end

  def shift({x, y}, direction, map) do
    current = map[{x, y}]

    new = get_new_position({x, y}, direction)

    {new_valid, _, map} =
      case map[new] do
        x when x in [:"[", :"]"] ->
          shift_box(new, direction, map)

        :. ->
          {:ok, new, map}

        :"#" ->
          {:blocked, {x, y}, map}
      end

    if new_valid == :ok do
      {:ok, new, Map.merge(map, %{new => current, {x, y} => :.})}
    else
      {:blocked, {x, y}, map}
    end
  end

  def generate_grid(map, {size_x, size_y}) do
    for i <- 0..(size_y - 1) do
      for j <- 0..(size_x - 1) do
        Map.get(map, {j, i})
      end
    end
    |> Enum.map(&Enum.join(&1))
    |> Enum.join("\n")
  end
end

[map, instructions] =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)

instructions =
  instructions
  |> String.codepoints()
  |> Enum.reject(fn x -> x == "\n" end)
  |> Enum.map(&String.to_atom/1)

map =
  map
  |> String.replace("O", "[]")
  |> String.replace("#", "##")
  |> String.replace(".", "..")
  |> String.replace("@", "@.")
  |> String.split("\n", trim: true)
  |> Enum.with_index()
  |> Enum.map(fn {line, row} ->
    String.codepoints(line)
    |> Enum.with_index()
    |> Enum.map(fn {cell, col} ->
      {{col, row}, String.to_atom(cell)}
    end)
  end)

map =
  map
  |> List.flatten()
  |> Map.new()

{start, _} = map |> Map.to_list() |> Enum.find(fn {_, x} -> x == :@ end)

reduced =
  Enum.reduce(instructions, {map, start}, fn instruction, {map, pos} ->
    {_, new_pos, new_map} = M.shift(pos, instruction, map)
    {new_map, new_pos}
  end)

box_gps =
  reduced
  |> elem(0)
  |> Map.to_list()
  |> Enum.filter(fn {_, x} -> x == :"[" end)
  |> Enum.map(fn {{x, y}, _} -> x + 100 * y end)

IO.inspect(box_gps |> Enum.sum())
