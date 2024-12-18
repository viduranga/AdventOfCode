defmodule M do
  import Bitwise

  def get_combo_arg(arg, registers) do
    case arg do
      4 -> registers[:a]
      5 -> registers[:b]
      6 -> registers[:c]
      _ -> arg
    end
  end

  def evaluate(op, arg, pointer, registers) do
    case op do
      :adv ->
        num = registers[:a]
        den = 2 ** get_combo_arg(arg, registers)
        res = div(num, den)

        {Map.put(registers, :a, res), pointer + 1}

      :bxl ->
        res = bxor(registers[:b], arg)
        {Map.put(registers, :b, res), pointer + 1}

      :bst ->
        res = rem(get_combo_arg(arg, registers), 8)

        {Map.put(registers, :b, res), pointer + 1}

      :jnz ->
        if registers[:a] != 0 do
          {registers, div(arg, 2)}
        else
          {registers, pointer + 1}
        end

      :bxc ->
        res = bxor(registers[:b], registers[:c])
        {Map.put(registers, :b, res), pointer + 1}

      :out ->
        res = rem(get_combo_arg(arg, registers), 8)
        IO.write("#{res},")
        {registers, pointer + 1}

      :bdv ->
        num = registers[:a]
        den = 2 ** get_combo_arg(arg, registers)
        res = div(num, den)

        {Map.put(registers, :b, res), pointer + 1}

      :cdv ->
        num = registers[:a]
        den = 2 ** get_combo_arg(arg, registers)
        res = div(num, den)

        {Map.put(registers, :c, res), pointer + 1}
    end
  end

  def step(registers, pointer, program, size) do
    if pointer >= size do
      {registers, pointer}
      IO.puts("")
    else
      {op, arg} = Enum.at(program, pointer)
      {registers, pointer} = evaluate(op, arg, pointer, registers)
      step(registers, pointer, program, size)
    end
  end
end

[registers, program] =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)
  |> Enum.map(&String.trim/1)

registers =
  Regex.named_captures(
    ~r/^Register A: (?<a>\d+)\nRegister B: (?<b>\d+)\nRegister C: (?<c>\d+)$/,
    registers
  )
  |> Enum.map(fn {key, val} -> {String.to_atom(key), String.to_integer(val)} end)
  |> Enum.into(%{})

program =
  String.split(program, " ", trim: true)
  |> Enum.at(1)
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)
  |> Enum.chunk_every(2)
  |> Enum.map(fn [op, arg] ->
    op =
      case op do
        0 -> :adv
        1 -> :bxl
        2 -> :bst
        3 -> :jnz
        4 -> :bxc
        5 -> :out
        6 -> :bdv
        7 -> :cdv
      end

    {op, arg}
  end)

M.step(registers, 0, program, Enum.count(program))
