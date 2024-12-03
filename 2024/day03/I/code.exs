content =
  System.argv()
  |> File.read!()

result =
  Regex.scan(~r/mul\(\d+,\d+\)/, content)
  |> Enum.map(fn [match] -> Regex.named_captures(~r/mul\((?<a>\d+),(?<b>\d+)\)/, match) end)
  |> Enum.map(fn %{"a" => a, "b" => b} -> String.to_integer(a) * String.to_integer(b) end)
  |> Enum.sum()

IO.inspect(result)
