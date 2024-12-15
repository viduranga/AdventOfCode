defmodule M do
  def fit(hdd, {fit_i, fit_size, _}) do
    move_i =
      hdd
      |> Enum.filter(fn {_, _, t} -> t == :free end)
      |> Enum.find_index(fn {i, free, _} ->
        free >= fit_size && i < fit_i
      end)

    case move_i do
      nil ->
        hdd

      _ ->
        hdd =
          hdd
          |> Enum.map(fn
            {i, size, type} when move_i == i and type == :free ->
              [{fit_i, fit_size, :file}, {i, size - fit_size, :free}]

            {i, _, type} when fit_i == i and type == :file ->
              {fit_i, fit_size, :free}

            elem ->
              elem
          end)
          |> List.flatten()

        hdd
    end
  end
end

# Read the file and parse the content
content =
  System.argv()
  |> File.read!()
  |> String.trim()
  |> String.codepoints()
  |> Enum.map(&String.to_integer/1)

hdd =
  content
  |> Enum.with_index()
  |> Enum.map(fn {v, i} ->
    if rem(i, 2) == 0, do: {div(i, 2), v, :file}, else: {div(i - 1, 2), v, :free}
  end)

fill =
  hdd
  |> Enum.filter(fn {_, _, t} -> t == :file end)
  |> Enum.reverse()

fitted =
  fill
  |> Enum.reduce(hdd, fn fill_chunk, acc ->
    M.fit(acc, fill_chunk)
  end)
  |> Enum.reject(fn {_, size, _} -> size == 0 end)

fitted =
  fitted
  |> Enum.map(fn {i, size, type} ->
    for _ <- 1..size,
        do: {i, type}
  end)
  |> List.flatten()

check_sum =
  fitted
  |> Enum.with_index()
  |> Enum.map(fn
    {{file_i, file_type}, i} when file_type == :file ->
      file_i * i

    _ ->
      0
  end)
  |> Enum.sum()

IO.inspect(check_sum)
