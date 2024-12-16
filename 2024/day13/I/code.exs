defmodule M do
  def calc_b(%{x: x, y: y, xa: xa, ya: ya, xb: xb, yb: yb}) do
    b = (xa * y - ya * x) / (xa * yb - xb * ya)
    b_whole = trunc(b)

    if b == b_whole do
      b_whole
    else
      nil
    end
  end

  def calc_a(nil, _) do
    nil
  end

  def calc_a(b, %{x: x, xa: xa, xb: xb}) do
    a = (x - b * xb) / xa
    a_whole = trunc(a)

    if a == a_whole do
      a_whole
    else
      nil
    end
  end
end

content =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)

eqs =
  content
  |> Enum.map(fn line ->
    Regex.named_captures(
      ~r/^Button A: X\+(?<xa>\d+), Y\+(?<ya>\d+)\nButton B: X\+(?<xb>\d+), Y\+(?<yb>\d+)\nPrize: X=(?<x>\d+), Y=(?<y>\d+)$/,
      line
    )
    |> Enum.map(fn {key, val} -> {String.to_atom(key), String.to_integer(val)} end)
    |> Enum.into(%{})
  end)

a_b =
  Enum.map(eqs, fn eq ->
    b = M.calc_b(eq)
    a = M.calc_a(b, eq)
    {a, b}
  end)
  |> Enum.reject(fn val -> val == {nil, nil} end)

tokens =
  a_b
  |> Enum.map(fn {a, b} -> a * 3 + b end)

IO.inspect(tokens |> Enum.sum())
