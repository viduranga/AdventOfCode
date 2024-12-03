defmodule M do
  def map_state(array) do
    Enum.chunk_every(array, 2, 1, :discard)
    |> Enum.map(fn [a, b] ->
      val =
        if !(abs(a - b) in 1..3),
          do: "invalid",
          else:
            (cond do
               a > b -> "decreasing"
               a < b -> "increasing"
               a == b -> "invalid"
             end)

      [[a, b], val]
    end)
  end

  def is_all_safe(array) do
    states = Enum.map(array, fn [_, val] -> val end)

    Enum.all?(states, fn x -> x == "increasing" end) ||
      Enum.all?(states, fn x -> x == "decreasing" end)
  end

  def is_safe_if_one_removed(array) do
    states = Enum.map(array, fn [_, state] -> state end)

    count = Enum.count(states)

    increasing_count = Enum.count(states, fn x -> x == "increasing" end)
    decreasing_count = Enum.count(states, fn x -> x == "decreasing" end)

    filter =
      cond do
        count - increasing_count == 1 -> "increasing"
        count - decreasing_count == 1 -> "decreasing"
        true -> "rejected"
      end

    if filter == "rejected",
      do: false,
      else:
        (
          flat = array |> Enum.map(fn [[a, _], state] -> [a, state] end)

          [[_, last], _] = Enum.at(array, -1)
          flat = flat ++ [[last, filter]]

          filtered =
            flat
            |> Enum.filter(fn [_, state] -> state == filter end)
            |> Enum.map(fn [x, _] -> x end)

          is_all_safe(map_state(filtered))
        )
  end

  def is_safe(array) do
    is_all_safe(array) ||
      is_safe_if_one_removed(array)
  end
end

# Read the file and parse the content
content =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x ->
    String.split(x, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end)

grouped =
  content
  |> Enum.map(fn x ->
    x
    |> M.map_state()
  end)

count =
  grouped
  |> Enum.count(fn x -> M.is_safe(x) end)

IO.inspect(count)
