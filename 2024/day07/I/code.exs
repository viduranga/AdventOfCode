defmodule M do
  def is_devisable?(x, by) do
    rem(x, by) == 0
  end

  def is_valid_equation?(lhs, rhs) do
    if Enum.count(lhs) == 0 do
      rhs == 0
    else
      [head | tail] = lhs

      (is_devisable?(rhs, head) && is_valid_equation?(tail, div(rhs, head))) ||
        (rhs >= head && is_valid_equation?(tail, rhs - head))
    end
  end
end

# Read the file and parse the content
content =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [rhs, lhs] = String.split(line, ":", trim: true)

    {
      String.to_integer(rhs),
      lhs |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
    }
  end)

valid_equations =
  content
  |> Enum.filter(fn {rhs, lhs} -> M.is_valid_equation?(Enum.reverse(lhs), rhs) end)

rhs_sum = Enum.sum(Enum.map(valid_equations, &elem(&1, 0)))

IO.inspect(rhs_sum)
