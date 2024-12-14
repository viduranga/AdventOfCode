defmodule M do
  def is_devisable?(x, by) do
    rem(x, by) == 0
  end

  def digit_length(x) do
    x |> Integer.digits() |> Enum.count()
  end

  def concat_ints(x, y) do
    x * 10 ** digit_length(y) + y
  end

  def is_valid_equation?(lhs, rhs) do
    [acc | rest] = lhs

    if Enum.count(rest) == 0 do
      rhs == acc
    else
      if rhs < acc do
        false
      else
        [head | tail] = rest

        is_valid_equation?([acc + head | tail], rhs) ||
          is_valid_equation?([acc * head | tail], rhs) ||
          is_valid_equation?([concat_ints(acc, head) | tail], rhs)
      end
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
  |> Enum.filter(fn {rhs, lhs} -> M.is_valid_equation?(lhs, rhs) end)

rhs_sum = Enum.sum(Enum.map(valid_equations, &elem(&1, 0)))

IO.inspect(rhs_sum)
