defmodule M do
  def combination(0, _), do: [[]]
  def combination(_, []), do: []

  def combination(n, [x | xs]) do
    for(y <- combination(n - 1, xs), do: [x | y]) ++ combination(n, xs)
  end

  def get_histogram(rows) do
    rows
    |> Enum.map(fn row ->
      String.codepoints(row)
      |> Enum.map(fn cell ->
        if cell == "#" do
          1
        else
          0
        end
      end)
    end)
  end
end

patterns =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)

%{:lock => locks, :key => keys} =
  patterns
  |> Enum.group_by(fn x ->
    if Regex.match?(~r/^#+\n/, x) do
      :lock
    else
      :key
    end
  end)

locks =
  locks
  |> Enum.map(fn lock ->
    String.split(lock, "\n", trim: true)
    |> M.get_histogram()
    |> Enum.zip()
    |> Enum.map(&Tuple.sum/1)
  end)

lock_height = 7

keys =
  keys
  |> Enum.map(fn key ->
    String.split(key, "\n", trim: true)
    |> M.get_histogram()
    |> Enum.zip()
    |> Enum.map(&Tuple.sum/1)
  end)

matches =
  Enum.map(keys, fn key ->
    Enum.map(locks, fn lock ->
      match =
        Enum.zip(key, lock)
        |> Enum.map(fn {k, l} -> lock_height >= k + l end)
        |> Enum.all?()

      {key, lock, match}
    end)
  end)
  |> List.flatten()
  |> Enum.filter(fn {_, _, match} -> match end)

IO.inspect(matches |> Enum.count())
