defmodule M do
  def combination(0, _), do: [[]]
  def combination(_, []), do: []

  def combination(n, [x | xs]) do
    for(y <- combination(n - 1, xs), do: [x | y]) ++ combination(n, xs)
  end

  def get_eq(val, conns, initial) do
    if Map.has_key?(initial, val) do
      initial[val]
    else
      {input1, gate, input2} = conns[val]
      input1_eq = get_eq(input1, conns, initial)
      input2_eq = get_eq(input2, conns, initial)

      gate <> "(" <> input1_eq <> "," <> input2_eq <> ")"
    end
  end
end

[initial, conns] =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)

conns =
  conns
  |> String.split("\n", trim: true)
  |> Enum.map(fn conn ->
    [inputs, output] = String.split(conn, " -> ", trim: true)
    [input1, gate, input2] = String.split(inputs, " ", trim: true)

    gate =
      case gate do
        "AND" -> "band"
        "OR" -> "bor"
        "XOR" -> "bxor"
      end

    {output, {input1, gate, input2}}
  end)
  |> Map.new()

IO.inspect(conns |> Enum.count())

initial =
  initial
  |> String.split("\n", trim: true)
  |> Enum.map(fn row ->
    [wire, value] = String.split(row, ": ", trim: true)
    {wire, value}
  end)
  |> Map.new()

end_wires =
  conns
  |> Enum.map(fn {wire, _} -> wire end)
  |> Enum.filter(fn wire -> String.starts_with?(wire, "z") end)
  |> Enum.sort()

eqs =
  end_wires
  |> Enum.map(fn wire -> M.get_eq(wire, conns, initial) end)

final =
  eqs
  |> Enum.map(fn eq -> Code.eval_string("import Bitwise;" <> eq) end)
  |> Enum.map(&elem(&1, 0))
  |> Enum.reverse()

IO.inspect(final |> Enum.join("") |> String.to_integer(2))
