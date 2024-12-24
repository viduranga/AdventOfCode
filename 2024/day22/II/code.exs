defmodule M do
  import Bitwise

  def mix(a, b) do
    bxor(a, b)
  end

  def ones(a) do
    rem(a, 10)
  end

  def ones_diff(a, b) do
    ones(a) - ones(b)
  end

  def prune(a) do
    rem(a, 16_777_216)
  end

  def next(magic) do
    magic = mix(magic, magic * 64) |> prune()
    magic = mix(magic, div(magic, 32)) |> prune()
    magic = mix(magic, magic * 2048) |> prune()

    magic
  end
end

init =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)

predictions =
  init
  |> Enum.map(fn magic ->
    Enum.map_reduce(1..2000, magic, fn _, prev ->
      next = M.next(prev)
      {{next, M.ones_diff(next, prev), magic}, next}
    end)
    |> elem(0)
    |> List.flatten()
  end)

change_seq =
  Enum.map(
    predictions,
    fn seq ->
      seq
      |> Enum.chunk_every(4, 1, :discard)
      |> Enum.map(fn chunk ->
        changes = Enum.map(chunk, fn {_, change, _} -> change end)
        magic = Enum.at(chunk, -1) |> elem(0)
        group = Enum.at(chunk, -1) |> elem(2)
        {changes, magic, group, M.ones(magic)}
      end)
    end
  )
  |> List.flatten()
  |> Enum.group_by(fn {changes, _, _, _} -> changes end, fn {_, magic, group, ones} ->
    {magic, group, ones}
  end)

best_seq =
  change_seq
  |> Enum.map(fn {seq, matches} ->
    matches =
      matches
      |> Enum.group_by(fn {_, init_magic, _} -> init_magic end)
      |> Enum.map(fn {_, matches} ->
        Enum.at(matches, 0) |> elem(2)
      end)

    {seq, matches}
  end)
  |> Enum.max_by(fn {_, ones} ->
    Enum.sum(ones)
  end)

IO.inspect(best_seq |> elem(1) |> Enum.sum())
