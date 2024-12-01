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
[first, second] = Enum.zip_with(content, &Function.identity/1)

frequencies = Enum.frequencies(second)

result =
  first
  |> Enum.map(fn a -> (frequencies[a] || 0) * a end)
  |> Enum.sum()

IO.inspect(result)
