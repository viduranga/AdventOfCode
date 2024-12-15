# Read the file and parse the content
content =
  System.argv()
  |> File.read!()
  |> String.trim()
  |> String.codepoints()
  |> Enum.map(&String.to_integer/1)

content = if rem(Enum.count(content), 2) == 0, do: content, else: content ++ [0]

files =
  content
  |> Enum.chunk_every(2, 2)
  |> Enum.map(fn [a, _] -> a end)

file_length = files |> Enum.sum()

files =
  files
  |> Enum.with_index()
  |> Enum.map(fn {file, index} ->
    for(_ <- 1..file, do: index)
  end)

free = content |> Enum.chunk_every(2, 2) |> Enum.map(fn [_, b] -> b end)

fill =
  files
  |> List.flatten()
  |> Enum.reverse()

{fill_chunks, _} =
  free
  |> Enum.map_reduce(fill, fn free, acc ->
    if free <= 0,
      do: {[], acc},
      else: {Enum.slice(acc, 0..(free - 1)), Enum.slice(acc, free..-1//1)}
  end)

files_indexed =
  files
  |> Enum.with_index()
  |> Enum.map(fn {v, i} -> {v, i * 2} end)

fills_indexed =
  fill_chunks
  |> Enum.with_index()
  |> Enum.map(fn {v, i} -> {v, i * 2 + 1} end)

merged =
  (files_indexed ++ fills_indexed)
  |> Enum.sort_by(&elem(&1, 1))
  |> Enum.map(&elem(&1, 0))
  |> List.flatten()
  |> Enum.slice(0..(file_length - 1))

checksum =
  merged
  |> Enum.with_index()
  |> Enum.map(fn {v, i} -> v * i end)
  |> Enum.sum()

IO.inspect(checksum)
