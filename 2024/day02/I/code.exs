defmodule M do
  def reverse_if_decreasing(x) do
    [a, b] = x |> Enum.take(2)
    if a > b, do: Enum.reverse(x), else: x
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

safes =
  content
  |> Enum.map(fn x ->
    x
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] ->
      if !(abs(a - b) in 1..3),
        do: "invalid",
        else:
          if(a > b,
            do: "decreasing",
            else: "increasing"
          )
    end)
  end)

safe_trues =
  safes
  |> Enum.count(fn s ->
    Enum.all?(s, fn x -> x == "increasing" end) || Enum.all?(s, fn x -> x == "decreasing" end)
  end)

IO.inspect(safe_trues)
