defmodule M do
  def pad(array, count, _) when count < 0 do
    array
  end

  def pad(array, count, loc) when count >= 0 do
    padding = Enum.map(0..count, fn _ -> " " end)

    case loc do
      :left -> padding ++ array
      :right -> array ++ padding
    end
  end

  def count_xmas(string) do
    count = String.split(string, "XMAS") |> Enum.count()
    count2 = String.split(string, "SAMX") |> Enum.count()
    count + count2 - 2
  end
end

# Read the file and parse the content

content =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x ->
    String.codepoints(x)
  end)

regular =
  content
  |> Enum.map(&Enum.join(&1))

# Transform (i.e. row to columns)
flipped =
  Enum.zip_with(content, &Function.identity/1)
  |> Enum.map(&Enum.join(&1))

diagonal_forward =
  Enum.with_index(content)
  |> Enum.map(fn {array, index} ->
    length = Enum.count(content)
    array = M.pad(array, index - 1, :left)
    array = M.pad(array, length - index - 2, :right)
    array
  end)
  |> Enum.zip_with(&Function.identity/1)
  |> Enum.map(&Enum.join(&1))

diagonal_backward =
  Enum.with_index(content)
  |> Enum.map(fn {array, index} ->
    length = Enum.count(content)
    array = M.pad(array, length - index - 1, :left)
    array = M.pad(array, index - 2, :right)
    array
  end)
  |> Enum.zip_with(&Function.identity/1)
  |> Enum.map(&Enum.join(&1))

result =
  (regular ++ flipped ++ diagonal_forward ++ diagonal_backward)
  |> Enum.map(&M.count_xmas/1)
  |> Enum.sum()

IO.inspect(result)
