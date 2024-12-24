defmodule M do
  import Bitwise

  def mix(a, b) do
    bxor(a, b)
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

final =
  init
  |> Enum.map(fn magic ->
    Enum.map_reduce(0..2000, magic, fn _, prev ->
      next = M.next(prev)
      {prev, next}
    end)
    |> elem(0)
    |> List.flatten()
  end)
  |> Enum.map(fn vals ->
    Enum.at(vals, -1)
  end)

IO.inspect(final |> Enum.sum())
