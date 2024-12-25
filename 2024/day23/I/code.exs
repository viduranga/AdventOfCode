defmodule M do
  def combination(0, _), do: [[]]
  def combination(_, []), do: []

  def combination(n, [x | xs]) do
    for(y <- combination(n - 1, xs), do: [x | y]) ++ combination(n, xs)
  end
end

conn =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn conn ->
    [n1, n2] = String.split(conn, "-", trim: true)
    [{n1, n2}, {n2, n1}]
  end)
  |> List.flatten()

nodes =
  conn
  |> Enum.group_by(fn {n, _} -> n end, fn {_, n} -> n end)
  |> Enum.map(fn {n, connected} ->
    M.combination(2, connected)
    |> Enum.filter(fn [n1, n2] ->
      Enum.any?([n, n1, n2], &String.starts_with?(&1, "t")) &&
        Enum.member?(conn, {n1, n2})
    end)
    |> Enum.map(fn [n1, n2] -> MapSet.new([n, n1, n2]) end)
  end)
  |> List.flatten()
  |> Enum.uniq()

IO.inspect(nodes |> Enum.count())
