defmodule M do
  def has_x_mas(arrays) do
    string = Enum.join(Enum.map(arrays, &Enum.join(&1)))

    first_match = Regex.match?(~r/^M.{3}A.{3}S|S.{3}A.{3}M$/, string)
    second_match = Regex.match?(~r/^.{2}M.A.S.{2}|.{2}S.A.M.{2}$/, string)

    first_match && second_match
  end
end

content =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x ->
    String.codepoints(x)
  end)

groups =
  content
  |> Enum.map(&Enum.chunk_every(&1, 3, 1, :discard))
  |> Enum.chunk_every(3, 1, :discard)
  |> Enum.map(&List.zip(&1))
  |> Enum.reduce(&Enum.concat/2)

result =
  groups
  |> Enum.filter(fn group -> group |> Tuple.to_list() |> M.has_x_mas() end)
  |> Enum.count()

IO.inspect(result)
