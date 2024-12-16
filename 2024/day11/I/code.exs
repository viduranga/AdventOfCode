defmodule M do
  def digits(number) do
    Integer.digits(number) |> length()
  end

  def split(number) do
    count = digits(number) |> div(2)

    [div(number, 10 ** count), rem(number, 10 ** count)]
  end

  def transform(number) do
    if number == 0 do
      1
    else
      if rem(digits(number), 2) == 0 do
        split(number)
      else
        number * 2024
      end
    end
  end

  def blink(stones) do
    Enum.map(stones, &transform/1) |> List.flatten()
  end
end

# Read the file and parse the content
content =
  System.argv()
  |> File.read!()
  |> String.trim()
  |> String.split(" ", trim: true)
  |> Enum.map(&String.to_integer/1)

stones_count =
  Enum.reduce(1..25, content, fn _, stones ->
    M.blink(stones)
  end)
  |> Enum.count()

IO.inspect(stones_count)
