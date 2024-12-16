defmodule M do
  def digits(number) do
    floor(:math.log10(number)) + 1
  end

  def transform(_, iter, memo) when iter == 0 do
    {1, memo}
  end

  def transform(number, iter, memo) when number == 0 do
    if Map.has_key?(memo, {number, iter}) do
      {memo[{number, iter}], memo}
    else
      {count, new_memo} = transform(1, iter - 1, memo)
      new_memo = Map.put(new_memo, {number, iter}, count)
      {count, new_memo}
    end
  end

  def transform(number, iter, memo) do
    if Map.has_key?(memo, {number, iter}) do
      {memo[{number, iter}], memo}
    else
      digits = digits(number)

      {count, new_memo} =
        if rem(digits, 2) == 0 do
          count = div(digits, 2)
          mult = 10 ** count

          first = div(number, mult)
          second = rem(number, mult)

          {count_first, memo_first} = transform(first, iter - 1, memo)
          {count_second, memo_second} = transform(second, iter - 1, memo_first)

          {count_first + count_second, memo_second}
        else
          transform(number * 2024, iter - 1, memo)
        end

      new_memo = Map.put(new_memo, {number, iter}, count)
      {count, new_memo}
    end
  end

  def blink(stones, iter) do
    stones
    |> Enum.map_reduce(Map.new(), fn stone, memo ->
      transform(stone, iter, memo)
    end)
    |> elem(0)
    |> Enum.sum()
  end
end

# Read the file and parse the content
content =
  System.argv()
  |> File.read!()
  |> String.trim()
  |> String.split(" ", trim: true)
  |> Enum.map(&String.to_integer/1)

stones_count = M.blink(content, 75)

IO.inspect(stones_count)
