defmodule M do
  def combination(0, _), do: [[]]
  def combination(_, []), do: []

  def combination(n, [x | xs]) do
    for(y <- combination(n - 1, xs), do: [x | y]) ++ combination(n, xs)
  end

  def bron_kerbosch(p, r, x, adj_map) do
    if MapSet.size(p) == 0 && MapSet.size(x) == 0 do
      [r |> Enum.sort()]
    else
      {_, _, result} =
        Enum.reduce(p, {p, x, []}, fn v, {p, x, result} ->
          out =
            M.bron_kerbosch(
              MapSet.intersection(p, adj_map[v]),
              MapSet.put(r, v),
              MapSet.intersection(x, adj_map[v]),
              adj_map
            )

          p = MapSet.delete(p, v)
          x = MapSet.put(x, v)

          {p, x, result ++ out}
        end)

      result
    end
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

adj_map =
  conn
  |> Enum.group_by(fn {n, _} -> n end, fn {_, n} -> n end)
  |> Enum.map(fn {k, v} -> {k, MapSet.new(v)} end)
  |> Map.new()

nodes =
  conn
  |> Enum.map(fn {n, _} -> n end)
  |> Enum.uniq()
  |> MapSet.new()

IO.inspect(
  M.bron_kerbosch(nodes, %MapSet{}, %MapSet{}, adj_map)
  |> Enum.max_by(&Enum.count/1)
  |> Enum.join(",")
)
