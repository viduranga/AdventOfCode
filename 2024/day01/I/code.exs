# Read the file and parse the content
content =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x ->
    String.split(x, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end)

# Transform (i.e. row to columns)
content = Enum.zip_with(content, &Function.identity/1)

result =
  content
  |> Enum.map(fn x -> Enum.sort(x) end)
  |> Enum.zip()
  |> Enum.map(fn {a, b} -> abs(a - b) end)
  |> Enum.sum()

IO.inspect(result)
